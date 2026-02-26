# Consistency Patterns — বাংলা ব্যাখ্যা

_টপিক নম্বর: 010_

## গল্পে বুঝি

মন্টু মিয়াঁ `বিড়ালটিউব`-এ একাধিক সার্ভার ও ডাটাবেজ রেপ্লিকা বসানোর পর দেখলেন, এক ইউজারের করা update আরেক ইউজারের স্ক্রিনে সাথে সাথে দেখা যাচ্ছে না। এই সমস্যাটা bug নাও হতে পারে; এটা consistency policy-র ফল।

`Consistency Patterns` টপিকটা মূলত বলে: সব data একইরকম guarantee চায় না। যেমন comment feed-এ ১-২ সেকেন্ড delay চলতে পারে, কিন্তু payment/subscription status-এ stale data খুব ঝুঁকিপূর্ণ।

এখানে আপনাকে ঠিক করতে হয় read path কোথায় যাবে, write কখন success ধরা হবে, replica lag accept করবেন কি না, এবং network partition হলে system availability নাকি strict correctness - কোনটা আগে রাখবেন।

এই কারণেই consistency discussion শুধুমাত্র database setting না; এটা product behavior-এর সাথে জড়িত design decision।

সহজ করে বললে `Consistency Patterns` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Consistency patterns describe how quickly and how reliably updates become visible across a ডিস্ট্রিবিউটেড সিস্টেম।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix`-এর মতো সিস্টেমে `Consistency Patterns`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Consistency Patterns` আসলে কীভাবে সাহায্য করে?

`Consistency Patterns` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- এক feature/API-র জন্য সবসময় একই consistency level না ধরে business-critical path আর non-critical path আলাদা করতে সাহায্য করে।
- read/write behavior (leader read, replica read, async propagation) user-visible outcome-এর সাথে map করতে সাহায্য করে।
- acceptable staleness, read-after-write expectation, আর endpoint-wise guarantee define করতে framework দেয়।
- “eventual” বা “strong” শব্দে থেমে না থেকে product behavior + cost + latency trade-off explain করতে সাহায্য করে।

---

### কখন `Consistency Patterns` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → যখন classifying endpoints এবং ডেটা entities by correctness requirements.
- Business value কোথায় বেশি? → Different features need different guarantees.
- কোন API/feature-এ strong consistency লাগবে, আর কোথায় eventual চলবে?
- write acknowledgment কোন শর্তে success ধরা হবে (leader/quorum/replica lag)?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না discuss কনসিসটেন্সি as a generic slogan detached from product behavior.
- ইন্টারভিউ রেড ফ্ল্যাগ: ব্যবহার করে "ইভেন্টুয়াল কনসিসটেন্সি" as an excuse জন্য undefined behavior.
- Thinking কনসিসটেন্সি patterns হলো শুধু ডাটাবেজ settings.
- Ignoring ক্লায়েন্ট-side expectations (যেমন, ইউজার expects to see তাদের own write).
- না defining acceptable staleness windows.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Consistency Patterns` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: ইউজার comment/like/post করল - write primary/leader node-এ গেল।
- ধাপ ২: replica-তে data copy হতে একটু দেরি হলো (replication lag)।
- ধাপ ৩: আরেক ইউজার replica থেকে read করলে পুরোনো data দেখতে পারে - এটাই eventual/weak behavior হতে পারে।
- ধাপ ৪: strong consistency চাইলে leader read/quorum/coordination লাগতে পারে; এতে latency ও complexity বাড়ে।
- ধাপ ৫: product-wise কোন endpoint-এ কোন guarantee acceptable - `Consistency Patterns` টপিক সেটা নির্ধারণে সাহায্য করে।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন API/feature-এ strong consistency লাগবে, আর কোথায় eventual চলবে?
- write acknowledgment কোন শর্তে success ধরা হবে (leader/quorum/replica lag)?
- user-facing behavior কী হবে: stale data accept করবেন, নাকি latency বাড়িয়ে fresh data দেবেন?

---

## এক লাইনে

- `Consistency Patterns` বিভিন্ন feature/API-র জন্য কোন consistency guarantee (weak/eventual/strong) লাগবে এবং তার user impact কী হবে, সেটি বেছে নেওয়ার টপিক।
- এই টপিকে বারবার আসতে পারে: consistency guarantees, staleness window, read-after-write, eventual consistency, strong consistency

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Consistency Patterns` ডেটা update-এর visibility guarantee, user-visible correctness expectation, আর consistency-level trade-off বোঝায়।

- কনসিসটেন্সি patterns describe how quickly এবং how reliably updates become visible জুড়ে a distributed সিস্টেম.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: replication/read-write path আলাদা হলে কোন data কখন visible হবে সেটা define না করলে user-visible inconsistency তৈরি হয়।

- Different features need different guarantees.
- একটি single কনসিসটেন্সি rule জন্য everything either costs too much অথবা breaks ইউজার expectations.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: endpoint/feature অনুযায়ী guarantee আলাদা করে, acceptable staleness ও partition behavior define করে design করা senior-level insight।

- Engineers choose কনসিসটেন্সি per workflow: read-পরে-write, monotonic reads, eventual, অথবা স্ট্রং কনসিসটেন্সি.
- Stronger guarantees usually increase coordination, ল্যাটেন্সি, এবং operational complexity.
- একটি senior design maps business invariants to কনসিসটেন্সি needs এর বদলে picking a ডাটাবেজ buzzword.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Consistency Patterns` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** recommendations পারে ব্যবহার stale signals, but account subscription changes should reflect quickly to এড়াতে billing/সাপোর্ট issues.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Consistency Patterns` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: যখন classifying endpoints এবং ডেটা entities by correctness requirements.
- কখন ব্যবহার করবেন না: করবেন না discuss কনসিসটেন্সি as a generic slogan detached from product behavior.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"যা কনসিসটেন্সি guarantees would আপনি assign to each major API?\"
- রেড ফ্ল্যাগ: ব্যবহার করে "ইভেন্টুয়াল কনসিসটেন্সি" as an excuse জন্য undefined behavior.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Consistency Patterns`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Thinking কনসিসটেন্সি patterns হলো শুধু ডাটাবেজ settings.
- Ignoring ক্লায়েন্ট-side expectations (যেমন, ইউজার expects to see তাদের own write).
- না defining acceptable staleness windows.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: ব্যবহার করে "ইভেন্টুয়াল কনসিসটেন্সি" as an excuse জন্য undefined behavior.
- কমন ভুল এড়ান: Thinking কনসিসটেন্সি patterns হলো শুধু ডাটাবেজ settings.
- Consistency টপিকে endpoint-by-endpoint guarantee (read-after-write, eventual, strong) বললে উত্তর অনেক পরিষ্কার হয়।
- কেন দরকার (শর্ট নোট): Different features need different guarantees.
