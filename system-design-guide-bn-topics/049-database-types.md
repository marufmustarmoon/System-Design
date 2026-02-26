# Database Types — বাংলা ব্যাখ্যা

_টপিক নম্বর: 049_

## গল্পে বুঝি

মন্টু মিয়াঁ `Database Types` টপিকটি পড়ছেন কারণ user/data বাড়ার সাথে সাথে database choice ও data layout সরাসরি system behavior-এ প্রভাব ফেলছে।

Database discussion-এ শুধু storage engine না; query pattern, consistency need, write/read ratio, indexing, replication, and operational complexity সব একসাথে আসে।

একই product-এ different data type-এর জন্য different stores/patterns লাগতে পারে - এটাকে দুর্বলতা না, design maturity হিসেবে দেখা হয়।

ইন্টারভিউতে data ownership, access pattern, and failure mode বললে database answer অনেক বেশি পরিষ্কার হয়।

সহজ করে বললে `Database Types` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Database types classify storage systems by data model and query/access pattern (relational, key-value, document, graph, etc.)।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Database Types`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Database Types` আসলে কীভাবে সাহায্য করে?

`Database Types` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- data model, access pattern, query path, আর scale requirement মিলিয়ে storage strategy explain করতে সাহায্য করে।
- indexing/replication/partitioning/sharding-এর দরকার কোথায় এবং কেন—সেটা স্পষ্ট করতে সহায়তা করে।
- consistency বনাম query flexibility বনাম operational complexity trade-off পরিষ্কার করে।
- database choice-কে brand preference নয়, workload-driven decision হিসেবে দেখাতে সাহায্য করে।

---

### কখন `Database Types` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → যখন mapping entities এবং access patterns to storage choices.
- Business value কোথায় বেশি? → Different ডেটা shapes এবং workloads require different storage ট্রেড-অফ.
- data model ও store type use-case অনুযায়ী ঠিক হচ্ছে কি?
- read/write pattern অনুযায়ী index/replication/sharding strategy লাগবে কি?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না choose a DB type by vendor familiarity alone.
- ইন্টারভিউ রেড ফ্ল্যাগ: Listing ডাটাবেজ types ছাড়া connecting them to queries.
- Thinking one DB type পারে optimally handle every workload.
- Ignoring operational maturity এবং tooling.
- Overfitting to current needs সাথে no growth path.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Database Types` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: data model ও entities নির্ধারণ করুন।
- ধাপ ২: access pattern (read/write/query) তালিকা করুন।
- ধাপ ৩: store/index/partition/replication strategy বেছে নিন।
- ধাপ ৪: consistency ও latency expectation explain করুন।
- ধাপ ৫: migration/operations/monitoring plan উল্লেখ করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- data model ও store type use-case অনুযায়ী ঠিক হচ্ছে কি?
- read/write pattern অনুযায়ী index/replication/sharding strategy লাগবে কি?
- consistency, query flexibility, এবং operational complexity-এর trade-off কী?

---

## এক লাইনে

- `Database Types` data model, storage layout, query pattern, scale, এবং consistency requirement মেলানোর database design টপিক।
- এই টপিকে বারবার আসতে পারে: data model, query pattern, indexing, consistency, scale trade-off

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Database Types` data modeling, storage choice, query pattern, আর scale/consistency requirement মেলানোর database design ধারণা দেয়।

- ডাটাবেজ types classify storage সিস্টেমগুলো by ডেটা model এবং query/access pattern (relational, কি-ভ্যালু, document, graph, etc.).

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ডেটার আকার, query complexity, write/read pressure বাড়লে data model ও storage strategy ভুল হলে system bottleneck হয়ে যায়।

- Different ডেটা shapes এবং workloads require different storage ট্রেড-অফ.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: data ownership, access pattern, indexing/partitioning, replication, এবং migration/operational overhead একসাথে explain করতে হয়।

- Type choice affects schema evolution, query flexibility, transaction সাপোর্ট, স্কেলিং model, এবং খরচ.
- Strong interview answers compare ডেটা access patterns আগে naming a DB product.
- Many সিস্টেমগুলো ব্যবহার multiple ডাটাবেজ types together (polyglot persistence).

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Database Types` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** products combine relational সিস্টেমগুলো জন্য transactions, কি-ভ্যালু/ডকুমেন্ট স্টোরs জন্য serving paths, এবং specialized stores জন্য graphs/analytics.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Database Types` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: যখন mapping entities এবং access patterns to storage choices.
- কখন ব্যবহার করবেন না: করবেন না choose a DB type by vendor familiarity alone.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Why হলো এটি workload a better fit জন্য a কি-ভ্যালু store than an RDBMS?\"
- রেড ফ্ল্যাগ: Listing ডাটাবেজ types ছাড়া connecting them to queries.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Database Types`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Thinking one DB type পারে optimally handle every workload.
- Ignoring operational maturity এবং tooling.
- Overfitting to current needs সাথে no growth path.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Listing ডাটাবেজ types ছাড়া connecting them to queries.
- কমন ভুল এড়ান: Thinking one DB type পারে optimally handle every workload.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): Different ডেটা shapes এবং workloads require different storage ট্রেড-অফ.
