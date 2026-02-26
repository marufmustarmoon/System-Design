# Message Queues — বাংলা ব্যাখ্যা

_টপিক নম্বর: 071_

## গল্পে বুঝি

মন্টু মিয়াঁ synchronous path হালকা করতে `মেসেজ কিউ` ব্যবহার করতে চান। request এলো, সব কাজ সঙ্গে সঙ্গে না করে queue-তে রেখে worker পরে প্রসেস করবে।

`Message Queues` টপিকটা decoupling, burst smoothing, এবং retryable async processing-এর core building block।

কিন্তু queue থাকলেই enough না - ordering, visibility timeout, retries, DLQ, duplicate processing, idempotency না ভাবলে production issue হবে।

ইন্টারভিউতে queue design বললে producer/consumer contract + failure semantics অবশ্যই বলুন।

সহজ করে বললে `Message Queues` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Message কিউs/brokers transport messages between producers and consumers, often supporting point-to-point or pub/sub patterns।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Message Queues`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Message Queues` আসলে কীভাবে সাহায্য করে?

`Message Queues` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- sync request path থেকে async workflow আলাদা করে decoupling ও burst smoothing design করতে সাহায্য করে।
- delivery semantics, retries, idempotency, DLQ, ordering, এবং lag—এসব operational concern structuring করে।
- producer/consumer responsibility ও failure path পরিষ্কার করে।
- workflow orchestration/notification/analytics-এর মতো fan-out flow cleanভাবে explain করতে সহায়তা করে।

---

### কখন `Message Queues` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → সার্ভিস decoupling, buffering, async integrations, ইভেন্ট-ড্রিভেন সিস্টেমগুলো.
- Business value কোথায় বেশি? → They decouple সার্ভিসগুলো, absorb bursts, এবং provide asynchronous communication সাথে buffering.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Simple synchronous রিকোয়েস্ট-রেসপন্স যেখানে queuing adds ল্যাটেন্সি এবং operational খরচ unnecessarily.
- ইন্টারভিউ রেড ফ্ল্যাগ: ব্যবহার করে a কিউ as a magic fix জন্য poor সার্ভিস boundaries.
- Confusing transport-level delivery সাথে business-level completion.
- Ignoring মেসেজ schema/versioning.
- Assuming ordering হলো global যখন it হলো অনেক সময় per-পার্টিশন/topic.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Message Queues` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: message/task payload ও schema define করুন।
- ধাপ ২: producer durability guarantee ঠিক করুন।
- ধাপ ৩: consumer ack/retry/idempotency flow ডিজাইন করুন।
- ধাপ ৪: poison message/DLQ handling যোগ করুন।
- ধাপ ৫: lag, processing time, retry rate monitor করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?
- consumer slow হলে back pressure/DLQ/retry policy কীভাবে কাজ করবে?

---

## এক লাইনে

- `Message Queues` async processing, queue/event flow, delivery behavior, এবং retry/idempotency design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: producer/consumer, ack/retry, DLQ, ordering, consumer lag

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Message Queues` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- মেসেজ কিউ/brokers transport মেসেজগুলো মাঝে প্রোডিউসারগুলো এবং কনজিউমারগুলো, অনেক সময় supporting point-to-point অথবা pub/sub patterns.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- They decouple সার্ভিসগুলো, absorb bursts, এবং provide asynchronous communication সাথে buffering.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- Brokers handle persistence, acknowledgments, ordering (sometimes), এবং delivery semantics.
- মেসেজ কিউ হলো transport infrastructure; business guarantees still require idempotency এবং consumer design.
- Compared সাথে টাস্ক কিউ, মেসেজ কিউ হলো অনেক সময় more general-purpose এবং পারে সাপোর্ট multiple integration patterns.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Message Queues` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** সার্ভিসগুলো পারে exchange order এবং fulfillment ইভেন্টগুলো উপর messaging infrastructure to decouple processing stages.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Message Queues` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: সার্ভিস decoupling, buffering, async integrations, ইভেন্ট-ড্রিভেন সিস্টেমগুলো.
- কখন ব্যবহার করবেন না: Simple synchronous রিকোয়েস্ট-রেসপন্স যেখানে queuing adds ল্যাটেন্সি এবং operational খরচ unnecessarily.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What delivery guarantee do আপনি need, এবং how will কনজিউমারগুলো handle duplicates?\"
- রেড ফ্ল্যাগ: ব্যবহার করে a কিউ as a magic fix জন্য poor সার্ভিস boundaries.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Message Queues`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Confusing transport-level delivery সাথে business-level completion.
- Ignoring মেসেজ schema/versioning.
- Assuming ordering হলো global যখন it হলো অনেক সময় per-পার্টিশন/topic.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: ব্যবহার করে a কিউ as a magic fix জন্য poor সার্ভিস boundaries.
- কমন ভুল এড়ান: Confusing transport-level delivery সাথে business-level completion.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): They decouple সার্ভিসগুলো, absorb bursts, এবং provide asynchronous communication সাথে buffering.
