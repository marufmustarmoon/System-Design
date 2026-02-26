# Improper Instantiation — বাংলা ব্যাখ্যা

_টপিক নম্বর: 086_

## গল্পে বুঝি

মন্টু মিয়াঁর সিস্টেমে `Improper Instantiation`-ধরনের সমস্যা দেখা দিচ্ছে: heavy object/client বারবার create হওয়ায় latency/CPU waste হচ্ছে।

এগুলো dangerous কারণ শুরুতে feature কাজ করে, কিন্তু scale বাড়লে hidden inefficiency explode করে।

Antipattern discussion-এ symptom, root cause, quick mitigation, long-term fix - এই চারটা বললে interviewer বুঝতে পারে আপনি production issues দেখেছেন।

শুধু “এটা খারাপ” বললে হবে না; কী metric দেখে ধরা যায় সেটাও বলা দরকার।

সহজ করে বললে `Improper Instantiation` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Improper instantiation means repeatedly creating expensive objects/resources instead of reusing them (DB connections, HTTP clients, thread pools, ক্যাশs)।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Improper Instantiation`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Improper Instantiation` আসলে কীভাবে সাহায্য করে?

`Improper Instantiation` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- hidden performance/reliability smell দ্রুত চিহ্নিত করতে symptom → root cause mapping দিতে সাহায্য করে।
- quick mitigation আর long-term structural fix আলাদা করে ভাবতে সহায়তা করে।
- scale বাড়লে কোন pattern কেন ভেঙে যায় তা interview-এ explain করতে সাহায্য করে।
- metrics-driven detection (latency, call count, DB load, retries) discussion-এ আনতে বাধ্য করে।

---

### কখন `Improper Instantiation` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → As a code-level পারফরম্যান্স review concern in সার্ভিস implementation discussions.
- Business value কোথায় বেশি? → Resource creation পারে হতে costly এবং পারে exhaust সিস্টেম limits এর অধীনে লোড.
- symptom কী (latency, DB load, extra calls, retry storm, CPU spike)?
- root cause কোন layer-এ (code path, data access, dependency pattern)?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না prematurely pool everything ছাড়া thread-safety/lifecycle analysis.
- ইন্টারভিউ রেড ফ্ল্যাগ: Per-রিকোয়েস্ট ক্লায়েন্ট object creation in high-QPS সার্ভিসগুলো.
- Assuming object creation খরচ হলো সবসময় trivial in production.
- Sharing non-thread-safe ক্লায়েন্টগুলো incorrectly.
- Forgetting cleanup of pooled resources.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Improper Instantiation` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Improper Instantiation` এমন একটি system-design antipattern/smell, যা scale বাড়লে performance বা reliability ভেঙে দিতে পারে।
- এই টপিকে বারবার আসতে পারে: improper, instantiation, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Improper Instantiation` এমন একটি system smell/antipattern বোঝায়, যেটা early detect না করলে scale-এ বড় সমস্যা তৈরি করে।

- Improper instantiation মানে repeatedly creating expensive objects/resources এর বদলে reusing them (DB connections, HTTP ক্লায়েন্টগুলো, thread pools, ক্যাশগুলো).

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: এই ধরনের antipattern শুরুতে ধরা না পড়লেও scale-এ latency, cost, reliability, বা developer productivity নষ্ট করে।

- Resource creation পারে হতে costly এবং পারে exhaust সিস্টেম limits এর অধীনে লোড.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: symptom → root cause → mitigation → structural fix chain-এ explain করলে antipattern discussion বাস্তবসম্মত হয়।

- Frequent re-creation increases CPU, memory churn, connection overhead, এবং ল্যাটেন্সি.
- Correct patterns ব্যবহার pooling, singleton/shared ক্লায়েন্টগুলো (যেখানে safe), এবং lifecycle management.
- ইন্টারভিউতে, এটি অনেক সময় appears as per-রিকোয়েস্ট DB connection creation অথবা per-call TLS ক্লায়েন্ট setup.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Improper Instantiation` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** সার্ভিস backends reuse connection pools এবং HTTP/gRPC ক্লায়েন্টগুলো এর বদলে creating new connections জন্য every রিকোয়েস্ট.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Improper Instantiation` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: As a code-level পারফরম্যান্স review concern in সার্ভিস implementation discussions.
- কখন ব্যবহার করবেন না: করবেন না prematurely pool everything ছাড়া thread-safety/lifecycle analysis.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Why হলো creating a new DB connection per রিকোয়েস্ট problematic?\"
- রেড ফ্ল্যাগ: Per-রিকোয়েস্ট ক্লায়েন্ট object creation in high-QPS সার্ভিসগুলো.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Improper Instantiation`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming object creation খরচ হলো সবসময় trivial in production.
- Sharing non-thread-safe ক্লায়েন্টগুলো incorrectly.
- Forgetting cleanup of pooled resources.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Per-রিকোয়েস্ট ক্লায়েন্ট object creation in high-QPS সার্ভিসগুলো.
- কমন ভুল এড়ান: Assuming object creation খরচ হলো সবসময় trivial in production.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Resource creation পারে হতে costly এবং পারে exhaust সিস্টেম limits এর অধীনে লোড.
