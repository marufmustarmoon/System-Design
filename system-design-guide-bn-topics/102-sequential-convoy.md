# Sequential Convoy — বাংলা ব্যাখ্যা

_টপিক নম্বর: 102_

## গল্পে বুঝি

মন্টু মিয়াঁ `Sequential Convoy` টপিকটি নিয়ে কাজ করছেন কারণ সব processing synchronous রাখলে request path ভারী হয়ে যাচ্ছে।

Messaging/async patterns burst smoothing, decoupling, and independent scaling-এ সাহায্য করে, কিন্তু delivery semantics ও operational complexity বাড়ায়।

এখানে ordering, retries, idempotency, DLQ, schema evolution, and tracing - এগুলো বাদ দিলে design অসম্পূর্ণ।

ইন্টারভিউতে এই টপিকগুলোতে flow diagram-এর সাথে failure path explain করলে দ্রুত clarity আসে।

সহজ করে বললে `Sequential Convoy` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Sequential convoy is a pattern where work that must stay ordered is processed in sequence, often by partition/key, to preserve correctness।

বাস্তব উদাহরণ ভাবতে চাইলে `Uber`-এর মতো সিস্টেমে `Sequential Convoy`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Sequential Convoy` আসলে কীভাবে সাহায্য করে?

`Sequential Convoy` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- sync request path থেকে async workflow আলাদা করে decoupling ও burst smoothing design করতে সাহায্য করে।
- delivery semantics, retries, idempotency, DLQ, ordering, এবং lag—এসব operational concern structuring করে।
- producer/consumer responsibility ও failure path পরিষ্কার করে।
- workflow orchestration/notification/analytics-এর মতো fan-out flow cleanভাবে explain করতে সহায়তা করে।

---

### কখন `Sequential Convoy` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Per-entity ordered workflows এবং স্টেট machines.
- Business value কোথায় বেশি? → Some workflows require strict ordering (যেমন, updates per ইউজার/order/account) এবং parallel কনজিউমারগুলো পারে break business rules.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Independent tasks যা পারে হতে processed in parallel ছাড়া ordering constraints.
- ইন্টারভিউ রেড ফ্ল্যাগ: Requiring global ordering যখন শুধু per-key ordering হলো needed.
- Serializing all মেসেজগুলো globally.
- Ignoring slow-মেসেজ blocking within a পার্টিশন.
- Choosing a পার্টিশন key যা causes hotspots.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Sequential Convoy` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Sequential Convoy` async processing, queue/event flow, delivery behavior, এবং retry/idempotency design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: sequential, convoy, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Sequential Convoy` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- Sequential convoy হলো a pattern যেখানে কাজ যা must stay ordered হলো processed in sequence, অনেক সময় by পার্টিশন/key, to preserve correctness.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- Some workflows require strict ordering (যেমন, updates per ইউজার/order/account) এবং parallel কনজিউমারগুলো পারে break business rules.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- মেসেজগুলো হলো grouped by key এবং routed to the same পার্টিশন/consumer so each key হলো processed in order.
- এটি preserves correctness but পারে create head-of-line blocking যদি one মেসেজ হলো slow.
- ট্রেড-অফ: correctness এবং simplicity vs থ্রুপুট এবং hotspot risk.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Sequential Convoy` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Uber** trip স্টেট ইভেন্টগুলো জন্য a single trip may need ordered processing to এড়াতে invalid transitions (end আগে start).

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Sequential Convoy` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Per-entity ordered workflows এবং স্টেট machines.
- কখন ব্যবহার করবেন না: Independent tasks যা পারে হতে processed in parallel ছাড়া ordering constraints.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি preserve per-ইউজার ordering ছাড়া making the whole সিস্টেম single-threaded?\"
- রেড ফ্ল্যাগ: Requiring global ordering যখন শুধু per-key ordering হলো needed.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Sequential Convoy`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Serializing all মেসেজগুলো globally.
- Ignoring slow-মেসেজ blocking within a পার্টিশন.
- Choosing a পার্টিশন key যা causes hotspots.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Requiring global ordering যখন শুধু per-key ordering হলো needed.
- কমন ভুল এড়ান: Serializing all মেসেজগুলো globally.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Some workflows require strict ordering (যেমন, updates per ইউজার/order/account) এবং parallel কনজিউমারগুলো পারে break business rules.
