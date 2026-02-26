# Extraneous Fetching — বাংলা ব্যাখ্যা

_টপিক নম্বর: 085_

## গল্পে বুঝি

মন্টু মিয়াঁর সিস্টেমে `Extraneous Fetching`-ধরনের সমস্যা দেখা দিচ্ছে: যতটুকু data দরকার তার চেয়ে বেশি data fetch হচ্ছে।

এগুলো dangerous কারণ শুরুতে feature কাজ করে, কিন্তু scale বাড়লে hidden inefficiency explode করে।

Antipattern discussion-এ symptom, root cause, quick mitigation, long-term fix - এই চারটা বললে interviewer বুঝতে পারে আপনি production issues দেখেছেন।

শুধু “এটা খারাপ” বললে হবে না; কী metric দেখে ধরা যায় সেটাও বলা দরকার।

সহজ করে বললে `Extraneous Fetching` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Extraneous fetching is retrieving data that the client or service does not actually need।

বাস্তব উদাহরণ ভাবতে চাইলে `YouTube`-এর মতো সিস্টেমে `Extraneous Fetching`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Extraneous Fetching` আসলে কীভাবে সাহায্য করে?

`Extraneous Fetching` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- hidden performance/reliability smell দ্রুত চিহ্নিত করতে symptom → root cause mapping দিতে সাহায্য করে।
- quick mitigation আর long-term structural fix আলাদা করে ভাবতে সহায়তা করে।
- scale বাড়লে কোন pattern কেন ভেঙে যায় তা interview-এ explain করতে সাহায্য করে।
- metrics-driven detection (latency, call count, DB load, retries) discussion-এ আনতে বাধ্য করে।

---

### কখন `Extraneous Fetching` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → যখন optimizing mobile ক্লায়েন্টগুলো অথবা high-QPS read APIs.
- Business value কোথায় বেশি? → এটি wastes bandwidth, CPU, memory, এবং ডাটাবেজ capacity, এবং increases ল্যাটেন্সি.
- symptom কী (latency, DB load, extra calls, retry storm, CPU spike)?
- root cause কোন layer-এ (code path, data access, dependency pattern)?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না উপর-customize রেসপন্সগুলো জন্য every ক্লায়েন্ট যদি it creates unmaintainable API sprawl.
- ইন্টারভিউ রেড ফ্ল্যাগ: Returning full objects সাথে large nested fields by default on list endpoints.
- Ignoring serialization/deserialization খরচ.
- কোনো field filtering অথবা pagination strategy.
- Solving সাথে ক্যাশ শুধু এর বদলে fixing রেসপন্স shape.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Extraneous Fetching` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Extraneous Fetching` এমন একটি system-design antipattern/smell, যা scale বাড়লে performance বা reliability ভেঙে দিতে পারে।
- এই টপিকে বারবার আসতে পারে: extraneous, fetching, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Extraneous Fetching` এমন একটি system smell/antipattern বোঝায়, যেটা early detect না করলে scale-এ বড় সমস্যা তৈরি করে।

- Extraneous fetching হলো retrieving ডেটা যা the ক্লায়েন্ট অথবা সার্ভিস does না actually need.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: এই ধরনের antipattern শুরুতে ধরা না পড়লেও scale-এ latency, cost, reliability, বা developer productivity নষ্ট করে।

- এটি wastes bandwidth, CPU, memory, এবং ডাটাবেজ capacity, এবং increases ল্যাটেন্সি.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: symptom → root cause → mitigation → structural fix chain-এ explain করলে antipattern discussion বাস্তবসম্মত হয়।

- এটি appears as উপর-fetching (too much ডেটা) অথবা এর অধীনে-fetching (too many follow-up calls), especially in generic APIs.
- Fixes include better DTOs, pagination, field selection, GraphQL, অথবা specialized endpoints/BFFs.
- Compare সাথে চ্যাটি I/O: extraneous fetching হলো about wrong ডেটা shape; চ্যাটি I/O হলো about too many calls (they অনেক সময় occur together).

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Extraneous Fetching` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **YouTube** home feed APIs should এড়াতে returning full video metadata blobs যখন শুধু card-summary fields হলো needed.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Extraneous Fetching` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: যখন optimizing mobile ক্লায়েন্টগুলো অথবা high-QPS read APIs.
- কখন ব্যবহার করবেন না: করবেন না উপর-customize রেসপন্সগুলো জন্য every ক্লায়েন্ট যদি it creates unmaintainable API sprawl.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি কমাতে উপর-fetching জন্য এটি UI screen?\"
- রেড ফ্ল্যাগ: Returning full objects সাথে large nested fields by default on list endpoints.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Extraneous Fetching`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Ignoring serialization/deserialization খরচ.
- কোনো field filtering অথবা pagination strategy.
- Solving সাথে ক্যাশ শুধু এর বদলে fixing রেসপন্স shape.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Returning full objects সাথে large nested fields by default on list endpoints.
- কমন ভুল এড়ান: Ignoring serialization/deserialization খরচ.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): এটি wastes bandwidth, CPU, memory, এবং ডাটাবেজ capacity, এবং increases ল্যাটেন্সি.
