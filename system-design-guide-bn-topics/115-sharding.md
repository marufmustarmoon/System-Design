# Sharding — বাংলা ব্যাখ্যা

_টপিক নম্বর: 115_

## গল্পে বুঝি

মন্টু মিয়াঁর database size ও write load এত বেড়েছে যে single DB instance bottleneck। index tuning করে কিছুটা লাভ হলেও capacity limit ধরা দিচ্ছে।

`Sharding` টপিকটা data-কে partition করে অনেক node-এ ছড়িয়ে load ভাগ করার ধারণা।

কিন্তু shard key ভুল হলে hot partition, uneven load, painful rebalancing, cross-shard query complexity - এগুলোই বড় সমস্যা হয়ে দাঁড়ায়।

তাই sharding আলোচনা মানে শুধু “mod N” না; data access pattern ও growth hotspot বুঝে key নির্বাচন করা।

সহজ করে বললে `Sharding` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: As a data management pattern, শার্ডিং means partitioning large datasets across multiple storage nodes to scale capacity and থ্রুপুট।

বাস্তব উদাহরণ ভাবতে চাইলে `WhatsApp`-এর মতো সিস্টেমে `Sharding`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Sharding` আসলে কীভাবে সাহায্য করে?

`Sharding` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- single database limit ছাড়িয়ে data/write scale বাড়াতে partitioning strategy নিয়ে concrete discussion করতে সাহায্য করে।
- shard key selection, skew/hot partition risk, আর rebalancing pain আগে থেকেই ভাবতে বাধ্য করে।
- cross-shard query/transaction complexity কোথায় বাড়বে তা পরিষ্কার করে।
- “mod N” টাইপ superficial answer-এর বদলে access-pattern-driven design explain করতে সাহায্য করে।

---

### কখন `Sharding` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Sustained growth in write থ্রুপুট অথবা storage size beyond ভার্টিক্যাল স্কেলিং.
- Business value কোথায় বেশি? → এটি lets the ডেটা layer grow beyond one machine’s storage, IOPS, এবং write limits.
- data model ও store type use-case অনুযায়ী ঠিক হচ্ছে কি?
- read/write pattern অনুযায়ী index/replication/sharding strategy লাগবে কি?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Early সিস্টেমগুলো সাথে low volume এবং uncertain access patterns.
- ইন্টারভিউ রেড ফ্ল্যাগ: শার্ডিং সাথে no plan জন্য cross-shard queries অথবা rebalancing.
- Hardcoding shard count forever.
- না separating shard key from business-facing IDs যখন needed.
- Ignoring operational tooling জন্য shard moves এবং repairs.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Sharding` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: shard key candidate বের করুন (user_id, region, tenant, time bucket ইত্যাদি)।
- ধাপ ২: access pattern/hot key risk analyze করুন।
- ধাপ ৩: routing layer বা shard map design করুন।
- ধাপ ৪: rebalancing/resharding strategy ভাবুন।
- ধাপ ৫: cross-shard queries/transactions কিভাবে handle করবেন তা বলুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- data model ও store type use-case অনুযায়ী ঠিক হচ্ছে কি?
- read/write pattern অনুযায়ী index/replication/sharding strategy লাগবে কি?
- consistency, query flexibility, এবং operational complexity-এর trade-off কী?

---

## এক লাইনে

- `Sharding` data-কে partitions/shards-এ ভাগ করে storage/write scale বাড়ানো এবং shard-key trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: shard key, hot partition, rebalancing, cross-shard queries, data distribution

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Sharding` data modeling, storage choice, query pattern, আর scale/consistency requirement মেলানোর database design ধারণা দেয়।

- As a ডেটা management pattern, শার্ডিং মানে partitioning large datasets জুড়ে multiple storage nodes to scale capacity এবং থ্রুপুট.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ডেটার আকার, query complexity, write/read pressure বাড়লে data model ও storage strategy ভুল হলে system bottleneck হয়ে যায়।

- এটি lets the ডেটা layer grow beyond one machine’s storage, IOPS, এবং write limits.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: data ownership, access pattern, indexing/partitioning, replication, এবং migration/operational overhead একসাথে explain করতে হয়।

- এই pattern হলো more than partitioning: it includes shard routing, rebalancing, resharding, এবং hotspot mitigation.
- Application-level শার্ডিং logic পারে leak into সার্ভিসগুলো unless hidden behind a routing/ডেটা-access layer.
- Compared সাথে the earlier ডাটাবেজ section, এটি view emphasizes operational lifecycle এবং ডেটা movement, না just schema design.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Sharding` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **WhatsApp**-scale messaging সিস্টেমগুলো shard ইউজার/মেসেজ metadata এবং must plan জন্য shard hotspots এবং migrations.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Sharding` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Sustained growth in write থ্রুপুট অথবা storage size beyond ভার্টিক্যাল স্কেলিং.
- কখন ব্যবহার করবেন না: Early সিস্টেমগুলো সাথে low volume এবং uncertain access patterns.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি reshard সাথে minimal downtime?\"
- রেড ফ্ল্যাগ: শার্ডিং সাথে no plan জন্য cross-shard queries অথবা rebalancing.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Sharding`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Hardcoding shard count forever.
- না separating shard key from business-facing IDs যখন needed.
- Ignoring operational tooling জন্য shard moves এবং repairs.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: শার্ডিং সাথে no plan জন্য cross-shard queries অথবা rebalancing.
- কমন ভুল এড়ান: Hardcoding shard count forever.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি lets the ডেটা layer grow beyond one machine’s storage, IOPS, এবং write limits.
