# Latency vs Throughput — বাংলা ব্যাখ্যা

_টপিক নম্বর: 005_

## গল্পে বুঝি

মন্টু মিয়াঁর system একেকটা request দ্রুত শেষ করতে পারে, কিন্তু একসাথে অনেক request এলে queue জমে যায়। আবার কোথাও bulk processing-এ throughput ভালো, কিন্তু individual request slow।

`Latency vs Throughput` টপিকটা বোঝায় fast single response আর high requests-per-second - এই দুই লক্ষ্য সবসময় একসাথে optimize করা যায় না।

batching, async processing, queueing throughput বাড়াতে পারে, কিন্তু client-visible latency বাড়তে পারে। উল্টোভাবে aggressive low-latency path resource efficiency কমাতে পারে।

ইন্টারভিউতে feature অনুযায়ী কোন metric primary (p95 latency, throughput, tail latency, batch completion time) সেটা আগে বলা জরুরি।

সহজ করে বললে `Latency vs Throughput` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Latency is the time for one request/task to complete।

বাস্তব উদাহরণ ভাবতে চাইলে `WhatsApp`-এর মতো সিস্টেমে `Latency vs Throughput`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Latency vs Throughput` আসলে কীভাবে সাহায্য করে?

`Latency vs Throughput` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- performance issue আর scalability issue আলাদা করে diagnose করতে সাহায্য করে।
- bottleneck কোন layer-এ (app/DB/cache/network) সেটা metrics-সহ explain করতে সাহায্য করে।
- short-term optimization বনাম long-term architecture change আলাদা করে plan করতে সাহায্য করে।
- traffic growth, cost, reliability—তিনটাকে একসাথে trade-off হিসেবে দেখাতে সাহায্য করে।

---

### কখন `Latency vs Throughput` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → যখন choosing sync vs async processing, batch size, অথবা queueing strategy.
- Business value কোথায় বেশি? → সিস্টেমগুলো অনেক সময় need one more than the other: ইউজার-facing APIs care about ল্যাটেন্সি; batch pipelines care about থ্রুপুট.
- এটা performance সমস্যা, না scalability সমস্যা, না architecture boundary সমস্যা?
- bottleneck কোন layer-এ (app/DB/network/cache)?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না treat average ল্যাটেন্সি alone as sufficient জন্য SLO discussion.
- ইন্টারভিউ রেড ফ্ল্যাগ: Ignoring p99 ল্যাটেন্সি on ইউজার-facing features.
- Confusing ল্যাটেন্সি এবং রেসপন্স size.
- ব্যবহার করে থ্রুপুট numbers ছাড়া discussing concurrency limits.
- Assuming lower ল্যাটেন্সি সবসময় মানে better overall সিস্টেম efficiency.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Latency vs Throughput` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: success metric ঠিক করুন - low latency না high throughput?
- ধাপ ২: workload type বুঝুন - interactive না batch?
- ধাপ ৩: queueing/batching/caching/parallelism-এর প্রভাব ব্যাখ্যা করুন।
- ধাপ ৪: p50 vs p95/p99 আলাদা করে দেখুন।
- ধাপ ৫: product requirement অনুযায়ী trade-off justify করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- এটা performance সমস্যা, না scalability সমস্যা, না architecture boundary সমস্যা?
- bottleneck কোন layer-এ (app/DB/network/cache)?
- short-term optimization আর long-term scaling design-এর মধ্যে কোনটা আগে দরকার?

---

## এক লাইনে

- `Latency vs Throughput` performance বনাম growth handling বুঝে bottleneck শনাক্ত করা এবং scale-ready optimization/architecture বেছে নেওয়ার টপিক।
- এই টপিকে বারবার আসতে পারে: bottleneck, capacity planning, latency/throughput, scaling strategy, cost trade-off

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Latency vs Throughput` টপিকটি performance issue আর scalability issue আলাদা করে বুঝে bottleneck-ভিত্তিক design decision নিতে সাহায্য করে।

- **ল্যাটেন্সি** হলো the time জন্য one রিকোয়েস্ট/task to complete.
- **থ্রুপুট** হলো how many রিকোয়েস্টগুলো/tasks the সিস্টেম processes per unit time.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: লোড ও data growth বাড়লে simple optimization যথেষ্ট নাও হতে পারে; bottleneck বুঝে scale strategy বেছে নিতে এই টপিক দরকার।

- সিস্টেমগুলো অনেক সময় need one more than the other: ইউজার-facing APIs care about ল্যাটেন্সি; batch pipelines care about থ্রুপুট.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: metrics, bottleneck layer, short-term optimization, long-term redesign, এবং cost impact একসাথে ব্যাখ্যা করাই senior-level approach।

- আপনি পারে increase থ্রুপুট সাথে batching এবং কিউগুলো, but যা may increase per-রিকোয়েস্ট ল্যাটেন্সি.
- Tail ল্যাটেন্সি (p95/p99) matters more than average ল্যাটেন্সি জন্য ইউজার experience.
- Compare them explicitly: optimizing one পারে hurt the other unless আপনি isolate workloads.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Latency vs Throughput` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **WhatsApp** মেসেজ send path targets low ল্যাটেন্সি জন্য delivery acknowledgment, যখন/একইসাথে media processing পারে prioritize থ্রুপুট.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Latency vs Throughput` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: যখন choosing sync vs async processing, batch size, অথবা queueing strategy.
- কখন ব্যবহার করবেন না: করবেন না treat average ল্যাটেন্সি alone as sufficient জন্য SLO discussion.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"যা metric matters more here, ল্যাটেন্সি অথবা থ্রুপুট, এবং why?\"
- রেড ফ্ল্যাগ: Ignoring p99 ল্যাটেন্সি on ইউজার-facing features.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Latency vs Throughput`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Confusing ল্যাটেন্সি এবং রেসপন্স size.
- ব্যবহার করে থ্রুপুট numbers ছাড়া discussing concurrency limits.
- Assuming lower ল্যাটেন্সি সবসময় মানে better overall সিস্টেম efficiency.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Ignoring p99 ল্যাটেন্সি on ইউজার-facing features.
- কমন ভুল এড়ান: Confusing ল্যাটেন্সি এবং রেসপন্স size.
- স্কেল/রিলায়েবিলিটি আলোচনায় traffic growth, failure case, আর cost একসাথে বলুন।
- কেন দরকার (শর্ট নোট): সিস্টেমগুলো অনেক সময় need one more than the other: ইউজার-facing APIs care about ল্যাটেন্সি; batch pipelines care about থ্রুপুট.
