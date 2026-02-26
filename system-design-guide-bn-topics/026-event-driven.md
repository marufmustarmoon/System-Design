# Event-Driven — বাংলা ব্যাখ্যা

_টপিক নম্বর: 026_

## গল্পে বুঝি

মন্টু মিয়াঁ চান এক feature-এর কাজ শেষ হলে অন্য সিস্টেমগুলো loosely coupled ভাবে react করুক - যেমন upload complete হলে analytics, notification, recommendation pipeline নিজে নিজে শুরু হবে।

`Event-Driven` টপিকটা এই event publication + subscriber reaction model বোঝায়।

এতে decoupling ও scalability বাড়ে, কিন্তু ordering, duplicate events, schema evolution, and observability challenge বাড়ে।

ইন্টারভিউতে event-driven design বললে event contract, delivery guarantee, idempotency, এবং replay behavior বলতেই হবে।

সহজ করে বললে `Event-Driven` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Event-driven processing triggers work when a specific event occurs (e.g., order placed, file uploaded)।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Event-Driven`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Event-Driven` আসলে কীভাবে সাহায্য করে?

`Event-Driven` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- services loosely coupled রেখে domain event-এর মাধ্যমে workflow trigger করতে সাহায্য করে।
- publisher/subscriber responsibility, event contract, আর async side effects আলাদা করে design করতে সাহায্য করে।
- idempotency, retries, schema evolution, observability—এসব operational concern আগেই ধরতে সাহায্য করে।
- one-to-many reaction flow (notification/analytics/recommendation) cleanভাবে model করতে সহায়তা করে।

---

### কখন `Event-Driven` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Reactive workflows, fan-out side effects, অডিট trails.
- Business value কোথায় বেশি? → এটি decouples প্রোডিউসারগুলো এবং কনজিউমারগুলো এবং অনুমতি দেয় multiple downstream actions ছাড়া tightly coupled synchronous calls.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Simple sequential workflows যেখানে synchronous calls হলো clearer এবং easier to debug.
- ইন্টারভিউ রেড ফ্ল্যাগ: Treating ইভেন্টগুলো as reliable commands ছাড়া আইডেমপোটেন্ট কনজিউমারগুলো.
- Confusing ইভেন্টগুলো (facts) সাথে commands (instructions).
- Ignoring schema versioning.
- Assuming pub/sub guarantees exactly-once business outcomes.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Event-Driven` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: domain event define করুন (name + payload schema)।
- ধাপ ২: publisher কবে event emit করবে ঠিক করুন।
- ধাপ ৩: subscribers idempotent handler implement করবে।
- ধাপ ৪: retries/DLQ/replay policy যুক্ত করুন।
- ধাপ ৫: event schema versioning ও tracing plan বলুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?
- consumer slow হলে back pressure/DLQ/retry policy কীভাবে কাজ করবে?

---

## এক লাইনে

- `Event-Driven` architecture-এ services/events loosely coupled ভাবে react করে, যেখানে delivery semantics ও idempotency design গুরুত্বপূর্ণ।
- এই টপিকে বারবার আসতে পারে: domain events, publish/subscribe, idempotent consumers, schema evolution, event tracing

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Event-Driven` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- ইভেন্ট-ড্রিভেন processing triggers কাজ যখন a specific ইভেন্ট occurs (যেমন, order placed, file uploaded).

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- এটি decouples প্রোডিউসারগুলো এবং কনজিউমারগুলো এবং অনুমতি দেয় multiple downstream actions ছাড়া tightly coupled synchronous calls.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- একটি প্রোডিউসার emits an ইভেন্ট to a broker/topic; কনজিউমারগুলো subscribe এবং process independently.
- Ordering, duplication, এবং schema evolution হলো the hard parts.
- Compared সাথে শিডিউল-ড্রিভেন jobs, ইভেন্ট-ড্রিভেন jobs হলো lower ল্যাটেন্সি এবং more reactive but need stronger ইভেন্ট contracts.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Event-Driven` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** order placement পারে emit ইভেন্টগুলো consumed by payment, inventory, notification, এবং analytics সার্ভিসগুলো.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Event-Driven` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Reactive workflows, fan-out side effects, অডিট trails.
- কখন ব্যবহার করবেন না: Simple sequential workflows যেখানে synchronous calls হলো clearer এবং easier to debug.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How will কনজিউমারগুলো handle duplicate অথবা out-of-order ইভেন্টগুলো?\"
- রেড ফ্ল্যাগ: Treating ইভেন্টগুলো as reliable commands ছাড়া আইডেমপোটেন্ট কনজিউমারগুলো.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Event-Driven`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Confusing ইভেন্টগুলো (facts) সাথে commands (instructions).
- Ignoring schema versioning.
- Assuming pub/sub guarantees exactly-once business outcomes.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Treating ইভেন্টগুলো as reliable commands ছাড়া আইডেমপোটেন্ট কনজিউমারগুলো.
- কমন ভুল এড়ান: Confusing ইভেন্টগুলো (facts) সাথে commands (instructions).
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): এটি decouples প্রোডিউসারগুলো এবং কনজিউমারগুলো এবং অনুমতি দেয় multiple downstream actions ছাড়া tightly coupled synchronous calls.
