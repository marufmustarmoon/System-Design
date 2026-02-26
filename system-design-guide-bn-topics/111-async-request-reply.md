# Async Request Reply — বাংলা ব্যাখ্যা

_টপিক নম্বর: 111_

## গল্পে বুঝি

মন্টু মিয়াঁর কিছু API কাজ ১০-৩০ সেকেন্ড লাগে। HTTP request খোলা রেখে user-কে অপেক্ষা করানো সবসময় ভালো UX না, আবার timeoutও হতে পারে।

`Async Request Reply` টপিকটা long-running কাজের result client-এ কীভাবে ফেরত দেবেন - সেই API design প্রশ্ন।

এখানে pattern হতে পারে: job ID দিয়ে polling, webhook callback, push notification, বা async request-reply. মূল কথা হলো status model পরিষ্কার করা।

User-visible states (queued/running/succeeded/failed/expired) define না করলে async flow confusing হয়ে যায়।

সহজ করে বললে `Async Request Reply` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Async request-reply is a pattern where a client submits a request, gets an acknowledgment immediately, and retrieves the result later asynchronously।

বাস্তব উদাহরণ ভাবতে চাইলে `Google, Amazon`-এর মতো সিস্টেমে `Async Request Reply`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Async Request Reply` আসলে কীভাবে সাহায্য করে?

`Async Request Reply` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- sync request path থেকে async workflow আলাদা করে decoupling ও burst smoothing design করতে সাহায্য করে।
- delivery semantics, retries, idempotency, DLQ, ordering, এবং lag—এসব operational concern structuring করে।
- producer/consumer responsibility ও failure path পরিষ্কার করে।
- workflow orchestration/notification/analytics-এর মতো fan-out flow cleanভাবে explain করতে সহায়তা করে।

---

### কখন `Async Request Reply` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → লং-রানিং jobs, batch exports, media processing, external integrations.
- Business value কোথায় বেশি? → Some operations take too long জন্য normal synchronous রিকোয়েস্ট timeouts.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Short operations যেখানে sync রেসপন্স fits ল্যাটেন্সি budgets.
- ইন্টারভিউ রেড ফ্ল্যাগ: Async API সাথে no status endpoint, timeout policy, অথবা result retention design.
- Treating initial acknowledgment as completion.
- কোনো cancellation/expiry semantics.
- Missing idempotency জন্য repeated submissions.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Async Request Reply` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: request accept করে durable job create করুন।
- ধাপ ২: 202 + job ID / tracking URL দিন।
- ধাপ ৩: status endpoint বা callback contract define করুন।
- ধাপ ৪: result retention/expiry policy ঠিক করুন।
- ধাপ ৫: failure/retry semantics client-কে স্পষ্ট করে জানান।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?
- consumer slow হলে back pressure/DLQ/retry policy কীভাবে কাজ করবে?

---

## এক লাইনে

- `Async Request Reply` async processing, queue/event flow, delivery behavior, এবং retry/idempotency design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: delivery semantics, retry policy, idempotency, ordering, DLQ/back pressure

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Async Request Reply` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- Async রিকোয়েস্ট-reply হলো a pattern যেখানে a ক্লায়েন্ট submits a রিকোয়েস্ট, gets an acknowledgment immediately, এবং retrieves the result later asynchronously.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- Some operations take too long জন্য normal synchronous রিকোয়েস্ট timeouts.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- এই সার্ভার creates a job, returns a tracking ID/status URL, এবং processes কাজ in the background.
- ক্লায়েন্টগুলো poll, receive callbacks/webhooks, অথবা subscribe to completion notifications.
- Compared সাথে synchronous RPC, এটি উন্নত করে responsiveness এবং reliability জন্য long tasks but complicates ক্লায়েন্ট UX এবং স্টেট handling.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Async Request Reply` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** অথবা **Amazon** export/report generation APIs অনেক সময় ব্যবহার async রিকোয়েস্ট-reply জন্য large dataset exports.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Async Request Reply` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: লং-রানিং jobs, batch exports, media processing, external integrations.
- কখন ব্যবহার করবেন না: Short operations যেখানে sync রেসপন্স fits ল্যাটেন্সি budgets.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What status model এবং API endpoints would আপনি expose জন্য async রিকোয়েস্ট-reply?\"
- রেড ফ্ল্যাগ: Async API সাথে no status endpoint, timeout policy, অথবা result retention design.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Async Request Reply`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating initial acknowledgment as completion.
- কোনো cancellation/expiry semantics.
- Missing idempotency জন্য repeated submissions.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Async API সাথে no status endpoint, timeout policy, অথবা result retention design.
- কমন ভুল এড়ান: Treating initial acknowledgment as completion.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Some operations take too long জন্য normal synchronous রিকোয়েস্ট timeouts.
