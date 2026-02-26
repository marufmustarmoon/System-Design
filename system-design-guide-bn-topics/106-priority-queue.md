# Priority Queue — বাংলা ব্যাখ্যা

_টপিক নম্বর: 106_

## গল্পে বুঝি

মন্টু মিয়াঁ `Priority Queue` টপিকটি নিয়ে কাজ করছেন কারণ সব processing synchronous রাখলে request path ভারী হয়ে যাচ্ছে।

Messaging/async patterns burst smoothing, decoupling, and independent scaling-এ সাহায্য করে, কিন্তু delivery semantics ও operational complexity বাড়ায়।

এখানে ordering, retries, idempotency, DLQ, schema evolution, and tracing - এগুলো বাদ দিলে design অসম্পূর্ণ।

ইন্টারভিউতে এই টপিকগুলোতে flow diagram-এর সাথে failure path explain করলে দ্রুত clarity আসে।

সহজ করে বললে `Priority Queue` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: A priority কিউ processes higher-priority messages/tasks before lower-priority ones।

বাস্তব উদাহরণ ভাবতে চাইলে `Uber`-এর মতো সিস্টেমে `Priority Queue`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Priority Queue` আসলে কীভাবে সাহায্য করে?

`Priority Queue` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- sync request path থেকে async workflow আলাদা করে decoupling ও burst smoothing design করতে সাহায্য করে।
- delivery semantics, retries, idempotency, DLQ, ordering, এবং lag—এসব operational concern structuring করে।
- producer/consumer responsibility ও failure path পরিষ্কার করে।
- workflow orchestration/notification/analytics-এর মতো fan-out flow cleanভাবে explain করতে সহায়তা করে।

---

### কখন `Priority Queue` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Mixed-criticality workloads sharing the same worker pool অথবা broker.
- Business value কোথায় বেশি? → না all কাজ has equal urgency; critical tasks should না wait behind low-value batch ট্রাফিক.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Uniform workloads যেখানে simple FIFO হলো easier এবং fairer.
- ইন্টারভিউ রেড ফ্ল্যাগ: Priority কিউ সাথে no fairness/aging policy.
- Too many priority levels সাথে unclear semantics.
- Letting every টিম mark tasks as highest priority.
- Ignoring মনিটরিং by priority class.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Priority Queue` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Priority Queue` async processing, queue/event flow, delivery behavior, এবং retry/idempotency design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: delivery semantics, retry policy, idempotency, ordering, DLQ/back pressure

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Priority Queue` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- একটি priority কিউ processes higher-priority মেসেজগুলো/tasks আগে lower-priority ones.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- না all কাজ has equal urgency; critical tasks should না wait behind low-value batch ট্রাফিক.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- Tasks হলো tagged সাথে priority levels এবং scheduled accordingly.
- Priority উন্নত করে responsiveness জন্য urgent কাজ but পারে starve low-priority tasks ছাড়া quotas অথবা aging.
- ট্রেড-অফ: better SLA control vs scheduling complexity এবং fairness concerns.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Priority Queue` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Uber** may prioritize rider-driver matching অথবা safety ইভেন্টগুলো উপর non-urgent notification jobs.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Priority Queue` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Mixed-criticality workloads sharing the same worker pool অথবা broker.
- কখন ব্যবহার করবেন না: Uniform workloads যেখানে simple FIFO হলো easier এবং fairer.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি রোধ করতে starvation in a priority কিউ?\"
- রেড ফ্ল্যাগ: Priority কিউ সাথে no fairness/aging policy.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Priority Queue`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Too many priority levels সাথে unclear semantics.
- Letting every টিম mark tasks as highest priority.
- Ignoring মনিটরিং by priority class.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Priority কিউ সাথে no fairness/aging policy.
- কমন ভুল এড়ান: Too many priority levels সাথে unclear semantics.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): না all কাজ has equal urgency; critical tasks should না wait behind low-value batch ট্রাফিক.
