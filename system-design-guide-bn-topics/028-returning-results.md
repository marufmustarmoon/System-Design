# Returning Results — বাংলা ব্যাখ্যা

_টপিক নম্বর: 028_

## গল্পে বুঝি

মন্টু মিয়াঁর কিছু API কাজ ১০-৩০ সেকেন্ড লাগে। HTTP request খোলা রেখে user-কে অপেক্ষা করানো সবসময় ভালো UX না, আবার timeoutও হতে পারে।

`Returning Results` টপিকটা long-running কাজের result client-এ কীভাবে ফেরত দেবেন - সেই API design প্রশ্ন।

এখানে pattern হতে পারে: job ID দিয়ে polling, webhook callback, push notification, বা async request-reply. মূল কথা হলো status model পরিষ্কার করা।

User-visible states (queued/running/succeeded/failed/expired) define না করলে async flow confusing হয়ে যায়।

সহজ করে বললে `Returning Results` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Returning results for background work means how clients learn task status and retrieve outputs after async processing।

বাস্তব উদাহরণ ভাবতে চাইলে `YouTube`-এর মতো সিস্টেমে `Returning Results`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Returning Results` আসলে কীভাবে সাহায্য করে?

`Returning Results` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- sync request path থেকে async workflow আলাদা করে decoupling ও burst smoothing design করতে সাহায্য করে।
- delivery semantics, retries, idempotency, DLQ, ordering, এবং lag—এসব operational concern structuring করে।
- producer/consumer responsibility ও failure path পরিষ্কার করে।
- workflow orchestration/notification/analytics-এর মতো fan-out flow cleanভাবে explain করতে সহায়তা করে।

---

### কখন `Returning Results` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → লং-রানিং tasks like exports, video processing, এবং bulk imports.
- Business value কোথায় বেশি? → ইউজাররা still need feedback, even যখন কাজ continues পরে the initial রিকোয়েস্ট returns.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Short operations যা পারে complete within normal রিকোয়েস্ট ল্যাটেন্সি budgets.
- ইন্টারভিউ রেড ফ্ল্যাগ: Saying "async" ছাড়া a ক্লায়েন্ট-visible status/result retrieval design.
- Returning 200 OK ছাড়া durable job creation.
- কোনো timeout/expiry policy জন্য stored results.
- Missing ফেইলিউর states অথবা রিট্রাই guidance in the API.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Returning Results` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Returning Results` async processing, queue/event flow, delivery behavior, এবং retry/idempotency design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: returning, results, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Returning Results` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- Returning results জন্য background কাজ মানে how ক্লায়েন্টগুলো learn task status এবং retrieve outputs পরে async processing.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- ইউজাররা still need feedback, even যখন কাজ continues পরে the initial রিকোয়েস্ট returns.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- Common patterns হলো polling status endpoints, webhooks, callbacks, email notifications, এবং WebSocket push.
- Polling হলো simplest but পারে waste লোড; push হলো efficient but requires delivery/সিকিউরিটি handling.
- এই API should return a job ID এবং explicit স্টেট model (`queued`, `running`, `succeeded`, `failed`).

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Returning Results` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **YouTube** upload API পারে return a video/job identifier যখন/একইসাথে the ক্লায়েন্ট later checks processing status আগে the video হলো playable.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Returning Results` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: লং-রানিং tasks like exports, video processing, এবং bulk imports.
- কখন ব্যবহার করবেন না: Short operations যা পারে complete within normal রিকোয়েস্ট ল্যাটেন্সি budgets.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Would আপনি choose polling অথবা webhooks here, এবং why?\"
- রেড ফ্ল্যাগ: Saying "async" ছাড়া a ক্লায়েন্ট-visible status/result retrieval design.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Returning Results`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Returning 200 OK ছাড়া durable job creation.
- কোনো timeout/expiry policy জন্য stored results.
- Missing ফেইলিউর states অথবা রিট্রাই guidance in the API.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Saying "async" ছাড়া a ক্লায়েন্ট-visible status/result retrieval design.
- কমন ভুল এড়ান: Returning 200 OK ছাড়া durable job creation.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): ইউজাররা still need feedback, even যখন কাজ continues পরে the initial রিকোয়েস্ট returns.
