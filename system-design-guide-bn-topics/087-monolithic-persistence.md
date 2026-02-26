# Monolithic Persistence — বাংলা ব্যাখ্যা

_টপিক নম্বর: 087_

## গল্পে বুঝি

মন্টু মিয়াঁর সিস্টেমে `Monolithic Persistence`-ধরনের সমস্যা দেখা দিচ্ছে: সব data access এক persistence pattern-এ আটকে গেছে।

এগুলো dangerous কারণ শুরুতে feature কাজ করে, কিন্তু scale বাড়লে hidden inefficiency explode করে।

Antipattern discussion-এ symptom, root cause, quick mitigation, long-term fix - এই চারটা বললে interviewer বুঝতে পারে আপনি production issues দেখেছেন।

শুধু “এটা খারাপ” বললে হবে না; কী metric দেখে ধরা যায় সেটাও বলা দরকার।

সহজ করে বললে `Monolithic Persistence` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Monolithic persistence means many unrelated services/features depend on one shared ডাটাবেজ schema/store as the central integration point।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Monolithic Persistence`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Monolithic Persistence` আসলে কীভাবে সাহায্য করে?

`Monolithic Persistence` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- hidden performance/reliability smell দ্রুত চিহ্নিত করতে symptom → root cause mapping দিতে সাহায্য করে।
- quick mitigation আর long-term structural fix আলাদা করে ভাবতে সহায়তা করে।
- scale বাড়লে কোন pattern কেন ভেঙে যায় তা interview-এ explain করতে সাহায্য করে।
- metrics-driven detection (latency, call count, DB load, retries) discussion-এ আনতে বাধ্য করে।

---

### কখন `Monolithic Persistence` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Small সিস্টেমগুলো/টিমগুলো early on, যেখানে simplicity হলো the top priority.
- Business value কোথায় বেশি? → এটি starts simple, but becomes a স্কেলিং এবং টিম coordination bottleneck উপর time.
- symptom কী (latency, DB load, extra calls, retry storm, CPU spike)?
- root cause কোন layer-এ (code path, data access, dependency pattern)?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Large multi-টিম সিস্টেমগুলো সাথে divergent scale এবং অ্যাভেইলেবিলিটি requirements.
- ইন্টারভিউ রেড ফ্ল্যাগ: Proposing microservices but keeping one shared DB জন্য all writes.
- Thinking separate সার্ভিসগুলো imply independence যখন/একইসাথে ডেটা হলো still shared.
- Ignoring migration coordination overhead.
- Splitting too late পরে operational pain হলো severe.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Monolithic Persistence` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: symptom metrics ধরুন (latency, call count, DB load, retries, CPU)।
- ধাপ ২: hotspot code path বা dependency pattern isolate করুন।
- ধাপ ৩: immediate containment fix দিন।
- ধাপ ৪: structural redesign plan করুন।
- ধাপ ৫: regression-prevention tests/monitoring যোগ করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- symptom কী (latency, DB load, extra calls, retry storm, CPU spike)?
- root cause কোন layer-এ (code path, data access, dependency pattern)?
- quick fix বনাম structural fix - কোনটা নিলে regression কমবে?

---

## এক লাইনে

- `Monolithic Persistence` এমন একটি system-design antipattern/smell, যা scale বাড়লে performance বা reliability ভেঙে দিতে পারে।
- এই টপিকে বারবার আসতে পারে: monolithic, persistence, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Monolithic Persistence` এমন একটি system smell/antipattern বোঝায়, যেটা early detect না করলে scale-এ বড় সমস্যা তৈরি করে।

- Monolithic persistence মানে many unrelated সার্ভিসগুলো/features depend on one shared ডাটাবেজ schema/store as the central integration point.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: এই ধরনের antipattern শুরুতে ধরা না পড়লেও scale-এ latency, cost, reliability, বা developer productivity নষ্ট করে।

- এটি starts simple, but becomes a স্কেলিং এবং টিম coordination bottleneck উপর time.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: symptom → root cause → mitigation → structural fix chain-এ explain করলে antipattern discussion বাস্তবসম্মত হয়।

- Shared schemas create coupling in ডিপ্লয়মেন্ট, migration, পারফরম্যান্স tuning, এবং ওনারশিপ.
- One noisy workload পারে degrade others; schema changes become high-risk.
- Compare সাথে federation/microservice-owned ডেটা: monolithic persistence simplifies joins early, but hurts autonomy এবং isolation later.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Monolithic Persistence` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon**-scale domains পারে না safely evolve যদি cart, orders, catalog, এবং payments all share one giant schema এবং release cycle.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Monolithic Persistence` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Small সিস্টেমগুলো/টিমগুলো early on, যেখানে simplicity হলো the top priority.
- কখন ব্যবহার করবেন না: Large multi-টিম সিস্টেমগুলো সাথে divergent scale এবং অ্যাভেইলেবিলিটি requirements.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What হলো the risks of sharing one ডাটাবেজ জুড়ে all microservices?\"
- রেড ফ্ল্যাগ: Proposing microservices but keeping one shared DB জন্য all writes.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Monolithic Persistence`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Thinking separate সার্ভিসগুলো imply independence যখন/একইসাথে ডেটা হলো still shared.
- Ignoring migration coordination overhead.
- Splitting too late পরে operational pain হলো severe.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Proposing microservices but keeping one shared DB জন্য all writes.
- কমন ভুল এড়ান: Thinking separate সার্ভিসগুলো imply independence যখন/একইসাথে ডেটা হলো still shared.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): এটি starts simple, but becomes a স্কেলিং এবং টিম coordination bottleneck উপর time.
