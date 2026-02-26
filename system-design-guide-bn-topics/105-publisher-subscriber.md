# Publisher / Subscriber — বাংলা ব্যাখ্যা

_টপিক নম্বর: 105_

## গল্পে বুঝি

মন্টু মিয়াঁ `Publisher / Subscriber` টপিকটি নিয়ে কাজ করছেন কারণ সব processing synchronous রাখলে request path ভারী হয়ে যাচ্ছে।

Messaging/async patterns burst smoothing, decoupling, and independent scaling-এ সাহায্য করে, কিন্তু delivery semantics ও operational complexity বাড়ায়।

এখানে ordering, retries, idempotency, DLQ, schema evolution, and tracing - এগুলো বাদ দিলে design অসম্পূর্ণ।

ইন্টারভিউতে এই টপিকগুলোতে flow diagram-এর সাথে failure path explain করলে দ্রুত clarity আসে।

সহজ করে বললে `Publisher / Subscriber` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Publisher/subscriber (pub/sub) is a messaging pattern where publishers emit events and multiple subscribers independently consume them।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Publisher / Subscriber`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Publisher / Subscriber` আসলে কীভাবে সাহায্য করে?

`Publisher / Subscriber` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- sync request path থেকে async workflow আলাদা করে decoupling ও burst smoothing design করতে সাহায্য করে।
- delivery semantics, retries, idempotency, DLQ, ordering, এবং lag—এসব operational concern structuring করে।
- producer/consumer responsibility ও failure path পরিষ্কার করে।
- workflow orchestration/notification/analytics-এর মতো fan-out flow cleanভাবে explain করতে সহায়তা করে।

---

### কখন `Publisher / Subscriber` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → ইভেন্ট-ড্রিভেন fan-out, analytics pipelines, loosely coupled integrations.
- Business value কোথায় বেশি? → এটি decouples প্রোডিউসারগুলো from many downstream কনজিউমারগুলো এবং সাপোর্ট করে fan-out ছাড়া প্রোডিউসার changes.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Command processing যেখানে exactly one worker should execute the job.
- ইন্টারভিউ রেড ফ্ল্যাগ: ব্যবহার করে pub/sub জন্য tightly coupled রিকোয়েস্ট-রেসপন্স workflows.
- কোনো schema compatibility strategy.
- Assuming all subscribers process at same speed.
- Ignoring replay/backfill impacts on downstream সিস্টেমগুলো.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Publisher / Subscriber` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: producer/consumer roles নির্ধারণ করুন।
- ধাপ ২: message schema ও durability guarantee বলুন।
- ধাপ ৩: retry/idempotency/DLQ policy দিন।
- ধাপ ৪: ordering/back pressure/consumer lag handle করুন।
- ধাপ ৫: monitoring + tracing দিয়ে pipeline observe করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?
- consumer slow হলে back pressure/DLQ/retry policy কীভাবে কাজ করবে?

---

## এক লাইনে

- `Publisher / Subscriber` async processing, queue/event flow, delivery behavior, এবং retry/idempotency design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: delivery semantics, retry policy, idempotency, ordering, DLQ/back pressure

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Publisher / Subscriber` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- Publisher/subscriber (pub/sub) হলো a messaging pattern যেখানে publishers emit ইভেন্টগুলো এবং multiple subscribers independently consume them.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- এটি decouples প্রোডিউসারগুলো from many downstream কনজিউমারগুলো এবং সাপোর্ট করে fan-out ছাড়া প্রোডিউসার changes.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- Topics/brokers route মেসেজগুলো to subscribers (অথবা subscriber groups).
- Pub/sub উন্নত করে extensibility, but ইভেন্ট contracts, ordering expectations, এবং replay semantics become important.
- Compared সাথে a task কিউ, pub/sub হলো জন্য broadcast/fan-out, না one-owner task execution.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Publisher / Subscriber` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** order-created ইভেন্টগুলো পারে fan out to notifications, analytics, fraud detection, এবং fulfillment workflows.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Publisher / Subscriber` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: ইভেন্ট-ড্রিভেন fan-out, analytics pipelines, loosely coupled integrations.
- কখন ব্যবহার করবেন না: Command processing যেখানে exactly one worker should execute the job.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি version ইভেন্টগুলো in a pub/sub সিস্টেম?\"
- রেড ফ্ল্যাগ: ব্যবহার করে pub/sub জন্য tightly coupled রিকোয়েস্ট-রেসপন্স workflows.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Publisher / Subscriber`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- কোনো schema compatibility strategy.
- Assuming all subscribers process at same speed.
- Ignoring replay/backfill impacts on downstream সিস্টেমগুলো.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: ব্যবহার করে pub/sub জন্য tightly coupled রিকোয়েস্ট-রেসপন্স workflows.
- কমন ভুল এড়ান: কোনো schema compatibility strategy.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): এটি decouples প্রোডিউসারগুলো from many downstream কনজিউমারগুলো এবং সাপোর্ট করে fan-out ছাড়া প্রোডিউসার changes.
