# Databases — বাংলা ব্যাখ্যা

_টপিক নম্বর: 042_

## গল্পে বুঝি

মন্টু মিয়াঁ `Databases` টপিকটি পড়ছেন কারণ user/data বাড়ার সাথে সাথে database choice ও data layout সরাসরি system behavior-এ প্রভাব ফেলছে।

Database discussion-এ শুধু storage engine না; query pattern, consistency need, write/read ratio, indexing, replication, and operational complexity সব একসাথে আসে।

একই product-এ different data type-এর জন্য different stores/patterns লাগতে পারে - এটাকে দুর্বলতা না, design maturity হিসেবে দেখা হয়।

ইন্টারভিউতে data ownership, access pattern, and failure mode বললে database answer অনেক বেশি পরিষ্কার হয়।

সহজ করে বললে `Databases` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Databases are systems for storing, querying, and updating application data reliably।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Databases`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Databases` আসলে কীভাবে সাহায্য করে?

`Databases` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- data model, access pattern, query path, আর scale requirement মিলিয়ে storage strategy explain করতে সাহায্য করে।
- indexing/replication/partitioning/sharding-এর দরকার কোথায় এবং কেন—সেটা স্পষ্ট করতে সহায়তা করে।
- consistency বনাম query flexibility বনাম operational complexity trade-off পরিষ্কার করে।
- database choice-কে brand preference নয়, workload-driven decision হিসেবে দেখাতে সাহায্য করে।

---

### কখন `Databases` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Any সিস্টেম সাথে durable স্টেট এবং query needs.
- Business value কোথায় বেশি? → Applications need durable স্টেট, indexing, querying, এবং concurrency control beyond simple files.
- data model ও store type use-case অনুযায়ী ঠিক হচ্ছে কি?
- read/write pattern অনুযায়ী index/replication/sharding strategy লাগবে কি?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না force one ডাটাবেজ to handle logs, graph traversal, এবং OLTP equally well.
- ইন্টারভিউ রেড ফ্ল্যাগ: Choosing a ডাটাবেজ by trend এর বদলে access pattern.
- Designing schema আগে defining queries.
- Ignoring backup/restore এবং migration strategy.
- Treating ডাটাবেজ choice as irreversible এর বদলে evolutionary.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Databases` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Databases` data model, storage layout, query pattern, scale, এবং consistency requirement মেলানোর database design টপিক।
- এই টপিকে বারবার আসতে পারে: data model, query pattern, indexing, consistency, scale trade-off

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Databases` data modeling, storage choice, query pattern, আর scale/consistency requirement মেলানোর database design ধারণা দেয়।

- ডাটাবেজগুলো হলো সিস্টেমগুলো জন্য storing, querying, এবং updating application ডেটা reliably.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ডেটার আকার, query complexity, write/read pressure বাড়লে data model ও storage strategy ভুল হলে system bottleneck হয়ে যায়।

- Applications need durable স্টেট, indexing, querying, এবং concurrency control beyond simple files.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: data ownership, access pattern, indexing/partitioning, replication, এবং migration/operational overhead একসাথে explain করতে হয়।

- ডাটাবেজ choice should follow access patterns, ডেটা relationships, কনসিসটেন্সি needs, এবং scale shape (read-heavy, write-heavy, analytical, graph-like).
- কোনো single ডাটাবেজ হলো best জন্য everything; many সিস্টেমগুলো ব্যবহার polyglot persistence.
- Interview strength comes from mapping ডেটা entities এবং query patterns আগে choosing technology.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Databases` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** products combine relational stores, কি-ভ্যালু stores, ডকুমেন্ট স্টোরs, এবং analytical সিস্টেমগুলো depending on workload.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Databases` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Any সিস্টেম সাথে durable স্টেট এবং query needs.
- কখন ব্যবহার করবেন না: করবেন না force one ডাটাবেজ to handle logs, graph traversal, এবং OLTP equally well.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি model এবং store the core entities জন্য এটি design?\"
- রেড ফ্ল্যাগ: Choosing a ডাটাবেজ by trend এর বদলে access pattern.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Databases`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Designing schema আগে defining queries.
- Ignoring backup/restore এবং migration strategy.
- Treating ডাটাবেজ choice as irreversible এর বদলে evolutionary.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Choosing a ডাটাবেজ by trend এর বদলে access pattern.
- কমন ভুল এড়ান: Designing schema আগে defining queries.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): Applications need durable স্টেট, indexing, querying, এবং concurrency control beyond simple files.
