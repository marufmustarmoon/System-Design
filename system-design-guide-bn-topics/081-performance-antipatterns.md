# Performance Antipatterns — বাংলা ব্যাখ্যা

_টপিক নম্বর: 081_

## গল্পে বুঝি

মন্টু মিয়াঁর সিস্টেমে `Performance Antipatterns`-ধরনের সমস্যা দেখা দিচ্ছে: সিস্টেমে এক ধরনের recurrent bad design symptom দেখা দিচ্ছে।

এগুলো dangerous কারণ শুরুতে feature কাজ করে, কিন্তু scale বাড়লে hidden inefficiency explode করে।

Antipattern discussion-এ symptom, root cause, quick mitigation, long-term fix - এই চারটা বললে interviewer বুঝতে পারে আপনি production issues দেখেছেন।

শুধু “এটা খারাপ” বললে হবে না; কী metric দেখে ধরা যায় সেটাও বলা দরকার।

সহজ করে বললে `Performance Antipatterns` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Performance antipatterns are recurring design mistakes that make systems slow, fragile, or expensive under load।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Performance Antipatterns`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Performance Antipatterns` আসলে কীভাবে সাহায্য করে?

`Performance Antipatterns` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- hidden performance/reliability smell দ্রুত চিহ্নিত করতে symptom → root cause mapping দিতে সাহায্য করে।
- quick mitigation আর long-term structural fix আলাদা করে ভাবতে সহায়তা করে।
- scale বাড়লে কোন pattern কেন ভেঙে যায় তা interview-এ explain করতে সাহায্য করে।
- metrics-driven detection (latency, call count, DB load, retries) discussion-এ আনতে বাধ্য করে।

---

### কখন `Performance Antipatterns` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → সময় ট্রেড-অফ এবং bottleneck discussions to show operational maturity.
- Business value কোথায় বেশি? → Interviewers want to know যদি আপনি পারে spot bottlenecks এবং poor architectural habits early.
- symptom কী (latency, DB load, extra calls, retry storm, CPU spike)?
- root cause কোন layer-এ (code path, data access, dependency pattern)?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না recite a list ছাড়া tying issues to the proposed design.
- ইন্টারভিউ রেড ফ্ল্যাগ: Assuming the initial design has no bottlenecks কারণ it হলো "distributed."
- Focusing শুধু on CPU এবং ignoring I/O এবং contention.
- Treating caching as the fix জন্য every antipattern.
- না considering tail ল্যাটেন্সি এবং saturation effects.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Performance Antipatterns` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Performance Antipatterns` এমন একটি system-design antipattern/smell, যা scale বাড়লে performance বা reliability ভেঙে দিতে পারে।
- এই টপিকে বারবার আসতে পারে: problem fit, data flow, trade-off, failure case, migration/operations

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Performance Antipatterns` এমন একটি system smell/antipattern বোঝায়, যেটা early detect না করলে scale-এ বড় সমস্যা তৈরি করে।

- পারফরম্যান্স antipatterns হলো recurring design mistakes যা make সিস্টেমগুলো slow, fragile, অথবা expensive এর অধীনে লোড.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: এই ধরনের antipattern শুরুতে ধরা না পড়লেও scale-এ latency, cost, reliability, বা developer productivity নষ্ট করে।

- Interviewers want to know যদি আপনি পারে spot bottlenecks এবং poor architectural habits early.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: symptom → root cause → mitigation → structural fix chain-এ explain করলে antipattern discussion বাস্তবসম্মত হয়।

- Antipatterns অনেক সময় look fine at low scale but break এর অধীনে concurrency, ডেটা growth, অথবা dependency ফেইলিউর.
- এই best mitigation হলো measurement plus architecture changes, না random tuning.
- Senior answers identify symptom, root cause, এবং design-level fix.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Performance Antipatterns` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** checkout পারফরম্যান্স পারে degrade যদি each রিকোয়েস্ট synchronously calls many সার্ভিসগুলো এবং repeats duplicate ডেটা fetches.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Performance Antipatterns` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: সময় ট্রেড-অফ এবং bottleneck discussions to show operational maturity.
- কখন ব্যবহার করবেন না: করবেন না recite a list ছাড়া tying issues to the proposed design.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What পারফরম্যান্স risks do আপনি see in আপনার own design?\"
- রেড ফ্ল্যাগ: Assuming the initial design has no bottlenecks কারণ it হলো "distributed."

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Performance Antipatterns`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Focusing শুধু on CPU এবং ignoring I/O এবং contention.
- Treating caching as the fix জন্য every antipattern.
- না considering tail ল্যাটেন্সি এবং saturation effects.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Assuming the initial design has no bottlenecks কারণ it হলো "distributed."
- কমন ভুল এড়ান: Focusing শুধু on CPU এবং ignoring I/O এবং contention.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Interviewers want to know যদি আপনি পারে spot bottlenecks এবং poor architectural habits early.
