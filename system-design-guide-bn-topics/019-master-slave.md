# Master-Slave — বাংলা ব্যাখ্যা

_টপিক নম্বর: 019_

## গল্পে বুঝি

মন্টু মিয়াঁ `Master-Slave` ধরনের replication model শিখছেন কারণ সব replica একই role পালন করে না। কারা write নেবে, কারা read serve করবে - এটা design-এর গুরুত্বপূর্ণ অংশ।

Single-writer model-এ write path সহজ হতে পারে কিন্তু writer bottleneck/ failover challenge থাকে। Multi-writer model-এ availability বাড়তে পারে কিন্তু conflict resolution কঠিন হয়।

বাস্তব সিস্টেমে model নির্বাচন product invariants, write contention, geo-distribution, এবং operational maturity-এর উপর নির্ভর করে।

এই টপিকে interviewer সাধারণত conflict, failover, lag, consistency নিয়ে follow-up করে।

সহজ করে বললে `Master-Slave` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Master-slave (primary-replica) রেপ্লিকেশন uses one writable node and one or more read-only replicas।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Master-Slave`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Master-Slave` আসলে কীভাবে সাহায্য করে?

`Master-Slave` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- টপিকটি কোন problem solve করে এবং কোন requirement-এ value দেয়—সেটা পরিষ্কার করতে সাহায্য করে।
- behavior, trade-off, limitation, আর user impact একসাথে design answer-এ আনতে সহায়তা করে।
- diagram/term-এর বাইরে operational implication explain করতে সাহায্য করে।
- interview answer-কে context-aware ও defensible করতে কাঠামো দেয়।

---

### কখন `Master-Slave` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Read-heavy workloads সাথে moderate write volume এবং clear primary ওনারশিপ.
- Business value কোথায় বেশি? → এটি simplifies write ordering এবং conflict handling.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Multi-রিজিয়ন write-heavy সিস্টেমগুলো needing local writes everywhere.
- ইন্টারভিউ রেড ফ্ল্যাগ: Sending all reads to replicas ছাড়া discussing read-পরে-write guarantees.
- Assuming failover to a replica হলো trivial.
- Forgetting replica promotion পারে lose latest async writes.
- ব্যবহার করে the term ছাড়া acknowledging primary/replica terminology in modern docs.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Master-Slave` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: writer topology ঠিক করুন (single vs multi)।
- ধাপ ২: read routing ও lag-aware reads policy নির্ধারণ করুন।
- ধাপ ৩: failover/switchover কীভাবে হবে বলুন।
- ধাপ ৪: conflict/duplicate writes (multi-writer হলে) handle করুন।
- ধাপ ৫: operational tooling/monitoring requirement উল্লেখ করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?
- degrade mode, failover, retry, throttling - কোনটা কখন চালু হবে?

---

## এক লাইনে

- `Master-Slave` সিস্টেম ডিজাইনের একটি গুরুত্বপূর্ণ ধারণা, যা requirement, behavior, এবং trade-off মিলিয়ে design decision নিতে সাহায্য করে।
- এই টপিকে বারবার আসতে পারে: master, slave, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Master-Slave` টপিকটি requirement, behavior, আর trade-off connect করে design decision নেওয়ার ধারণা পরিষ্কার করে।

- মাস্টার-স্লেভ (primary-replica) রেপ্লিকেশন ব্যবহার করে one writable node এবং one অথবা more read-শুধু replicas.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: বাস্তব সিস্টেমে scale, cost, correctness, এবং operational complexity সামলাতে এই ধারণা/প্যাটার্ন দরকার হয়।

- এটি simplifies write ordering এবং conflict handling.
- এটি হলো a common starting point জন্য read স্কেলিং এবং অ্যাভেইলেবিলিটি.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: internals-এর সাথে user-visible behavior, trade-off, এবং operational impact একসাথে ব্যাখ্যা করলে sectionটি শক্তিশালী হয়।

- Writes go to the primary; replicas replay the write log.
- Async replicas কমাতে write ল্যাটেন্সি but পারে lag; sync replicas উন্নত করতে ডিউরেবিলিটি/কনসিসটেন্সি but slow writes.
- Interviewers অনেক সময় expect আপনি to discuss read-পরে-write behavior, failover promotion, এবং replica lag handling.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Master-Slave` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** product catalog reads পারে হতে distributed to replicas যখন/একইসাথে catalog updates go to a primary ডাটাবেজ node.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Master-Slave` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Read-heavy workloads সাথে moderate write volume এবং clear primary ওনারশিপ.
- কখন ব্যবহার করবেন না: Multi-রিজিয়ন write-heavy সিস্টেমগুলো needing local writes everywhere.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How do আপনি handle ইউজাররা reading stale ডেটা পরে they just wrote?\"
- রেড ফ্ল্যাগ: Sending all reads to replicas ছাড়া discussing read-পরে-write guarantees.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Master-Slave`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming failover to a replica হলো trivial.
- Forgetting replica promotion পারে lose latest async writes.
- ব্যবহার করে the term ছাড়া acknowledging primary/replica terminology in modern docs.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Sending all reads to replicas ছাড়া discussing read-পরে-write guarantees.
- কমন ভুল এড়ান: Assuming failover to a replica হলো trivial.
- Consistency টপিকে endpoint-by-endpoint guarantee (read-after-write, eventual, strong) বললে উত্তর অনেক পরিষ্কার হয়।
- কেন দরকার (শর্ট নোট): এটি simplifies write ordering এবং conflict handling.
