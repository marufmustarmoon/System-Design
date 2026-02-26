# Task Queues — বাংলা ব্যাখ্যা

_টপিক নম্বর: 070_

## গল্পে বুঝি

মন্টু মিয়াঁ synchronous path হালকা করতে `টাস্ক কিউ` ব্যবহার করতে চান। request এলো, সব কাজ সঙ্গে সঙ্গে না করে queue-তে রেখে worker পরে প্রসেস করবে।

`Task Queues` টপিকটা decoupling, burst smoothing, এবং retryable async processing-এর core building block।

কিন্তু queue থাকলেই enough না - ordering, visibility timeout, retries, DLQ, duplicate processing, idempotency না ভাবলে production issue হবে।

ইন্টারভিউতে queue design বললে producer/consumer contract + failure semantics অবশ্যই বলুন।

সহজ করে বললে `Task Queues` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Task কিউs hold units of work to be processed by worker processes, often for ব্যাকগ্রাউন্ড জব owned by one application/team।

বাস্তব উদাহরণ ভাবতে চাইলে `Uber`-এর মতো সিস্টেমে `Task Queues`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Task Queues` আসলে কীভাবে সাহায্য করে?

`Task Queues` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- sync request path থেকে async workflow আলাদা করে decoupling ও burst smoothing design করতে সাহায্য করে।
- delivery semantics, retries, idempotency, DLQ, ordering, এবং lag—এসব operational concern structuring করে।
- producer/consumer responsibility ও failure path পরিষ্কার করে।
- workflow orchestration/notification/analytics-এর মতো fan-out flow cleanভাবে explain করতে সহায়তা করে।

---

### কখন `Task Queues` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → ব্যাকগ্রাউন্ড জব, রিট্রাইগুলো, deferred processing, লোড smoothing.
- Business value কোথায় বেশি? → They decouple রিকোয়েস্ট handling from slow processing এবং smooth ট্রাফিক bursts.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Broadcasting ইভেন্টগুলো to many independent কনজিউমারগুলো (pub/sub fits better).
- ইন্টারভিউ রেড ফ্ল্যাগ: Assuming exactly-once execution from the কিউ সিস্টেম.
- কোনো dead-letter কিউ জন্য poison মেসেজগুলো.
- Coupling workers to the প্রোডিউসার’s ডাটাবেজ transactions incorrectly.
- Ignoring task visibility timeout tuning.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Task Queues` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Task Queues` async processing, queue/event flow, delivery behavior, এবং retry/idempotency design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: job dispatch, worker pool, retries, visibility timeout, job idempotency

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Task Queues` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- টাস্ক কিউ hold units of কাজ to হতে processed by worker processes, অনেক সময় জন্য ব্যাকগ্রাউন্ড জব owned by one application/টিম.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- They decouple রিকোয়েস্ট handling from slow processing এবং smooth ট্রাফিক bursts.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- একটি প্রোডিউসার enqueues tasks; workers pull tasks এবং execute them সাথে রিট্রাই/visibility timeout semantics.
- টাস্ক কিউ হলো অনেক সময় command-oriented ("do X") সাথে business-specific payloads এবং status tracking.
- Compared সাথে মেসেজ কিউ/pub-sub, টাস্ক কিউ usually imply কাজ ওনারশিপ by one consumer worker group.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Task Queues` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Uber** পারে enqueue receipt generation অথবা trip summary email tasks পরে trip completion.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Task Queues` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: ব্যাকগ্রাউন্ড জব, রিট্রাইগুলো, deferred processing, লোড smoothing.
- কখন ব্যবহার করবেন না: Broadcasting ইভেন্টগুলো to many independent কনজিউমারগুলো (pub/sub fits better).
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How do আপনি make task processing আইডেমপোটেন্ট যখন রিট্রাইগুলো happen?\"
- রেড ফ্ল্যাগ: Assuming exactly-once execution from the কিউ সিস্টেম.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Task Queues`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- কোনো dead-letter কিউ জন্য poison মেসেজগুলো.
- Coupling workers to the প্রোডিউসার’s ডাটাবেজ transactions incorrectly.
- Ignoring task visibility timeout tuning.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Assuming exactly-once execution from the কিউ সিস্টেম.
- কমন ভুল এড়ান: কোনো dead-letter কিউ জন্য poison মেসেজগুলো.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): They decouple রিকোয়েস্ট handling from slow processing এবং smooth ট্রাফিক bursts.
