# Choreography — বাংলা ব্যাখ্যা

_টপিক নম্বর: 109_

## গল্পে বুঝি

মন্টু মিয়াঁ `Choreography` টপিকটি নিয়ে কাজ করছেন কারণ সব processing synchronous রাখলে request path ভারী হয়ে যাচ্ছে।

Messaging/async patterns burst smoothing, decoupling, and independent scaling-এ সাহায্য করে, কিন্তু delivery semantics ও operational complexity বাড়ায়।

এখানে ordering, retries, idempotency, DLQ, schema evolution, and tracing - এগুলো বাদ দিলে design অসম্পূর্ণ।

ইন্টারভিউতে এই টপিকগুলোতে flow diagram-এর সাথে failure path explain করলে দ্রুত clarity আসে।

সহজ করে বললে `Choreography` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Choreography is a workflow style where services react to events and coordinate indirectly, without a central orchestrator।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Choreography`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Choreography` আসলে কীভাবে সাহায্য করে?

`Choreography` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- sync request path থেকে async workflow আলাদা করে decoupling ও burst smoothing design করতে সাহায্য করে।
- delivery semantics, retries, idempotency, DLQ, ordering, এবং lag—এসব operational concern structuring করে।
- producer/consumer responsibility ও failure path পরিষ্কার করে।
- workflow orchestration/notification/analytics-এর মতো fan-out flow cleanভাবে explain করতে সহায়তা করে।

---

### কখন `Choreography` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Loosely coupled ইভেন্ট-ড্রিভেন workflows সাথে independent domain সার্ভিসগুলো.
- Business value কোথায় বেশি? → এটি কমায় central workflow coupling এবং অনুমতি দেয় সার্ভিসগুলো to evolve independently.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Complex workflows requiring centralized deadlines, compensations, অথবা strict sequencing.
- ইন্টারভিউ রেড ফ্ল্যাগ: Choreography সাথে no ইভেন্ট tracing/correlation IDs.
- Losing track of workflow ওনারশিপ.
- Too many implicit ইভেন্ট dependencies.
- কোনো schema governance জুড়ে টিমগুলো.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Choreography` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Choreography` async processing, queue/event flow, delivery behavior, এবং retry/idempotency design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: data model, query pattern, indexing, consistency, scale trade-off

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Choreography` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- Choreography হলো a workflow style যেখানে সার্ভিসগুলো react to ইভেন্টগুলো এবং coordinate indirectly, ছাড়া a central orchestrator.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- এটি কমায় central workflow coupling এবং অনুমতি দেয় সার্ভিসগুলো to evolve independently.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- Each সার্ভিস listens জন্য ইভেন্টগুলো এবং emits new ইভেন্টগুলো যখন it completes local কাজ.
- এটি হলো flexible এবং decoupled, but end-to-end flow visibility এবং debugging হলো harder than orchestration.
- Compare সাথে orchestration/supervisor patterns: choreography কমায় control-plane centralization but increases emergent complexity.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Choreography` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** order pipelines পারে ব্যবহার ইভেন্ট choreography যেখানে inventory, shipment, এবং notification সার্ভিসগুলো react to order ইভেন্টগুলো.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Choreography` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Loosely coupled ইভেন্ট-ড্রিভেন workflows সাথে independent domain সার্ভিসগুলো.
- কখন ব্যবহার করবেন না: Complex workflows requiring centralized deadlines, compensations, অথবা strict sequencing.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What হলো the observability challenges of choreography?\"
- রেড ফ্ল্যাগ: Choreography সাথে no ইভেন্ট tracing/correlation IDs.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Choreography`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Losing track of workflow ওনারশিপ.
- Too many implicit ইভেন্ট dependencies.
- কোনো schema governance জুড়ে টিমগুলো.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Choreography সাথে no ইভেন্ট tracing/correlation IDs.
- কমন ভুল এড়ান: Losing track of workflow ওনারশিপ.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি কমায় central workflow coupling এবং অনুমতি দেয় সার্ভিসগুলো to evolve independently.
