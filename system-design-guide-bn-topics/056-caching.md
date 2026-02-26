# Caching — বাংলা ব্যাখ্যা

_টপিক নম্বর: 056_

## গল্পে বুঝি

মন্টু মিয়াঁ দেখলেন একই data বারবার request হচ্ছে। প্রতিবার origin/DB-তে যাওয়ায় latency বাড়ছে এবং backend অযথা চাপ খাচ্ছে।

`Caching` টপিকটা সেই repeated read workload optimize করার কৌশল নিয়ে।

ক্যাশ speed বাড়ায়, কিন্তু freshness/invalidation/security/personalization mismatch হলে ভুল data serve হতে পারে - তাই cache design আসলে correctness discussion-ও।

এজন্য interview-তে cache mention করলেই key, TTL, invalidation, miss behavior, stampede protection বলা উচিত।

সহজ করে বললে `Caching` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Caching stores frequently used data in a faster layer (memory or edge) to reduce repeated expensive work।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Caching`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Caching` আসলে কীভাবে সাহায্য করে?

`Caching` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- repeated read workload-এ latency ও origin/DB load কমানোর strategy পরিষ্কার করে।
- cache key, TTL, invalidation, miss behavior, এবং stale-data risk একসাথে discuss করতে সাহায্য করে।
- cache placement (client/CDN/app/DB layer) workload অনুযায়ী বেছে নিতে সহায়তা করে।
- cache stampede বা wrong-user cache issue-এর মতো practical সমস্যা আগে থেকেই ধরতে সাহায্য করে।

---

### কখন `Caching` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Read-heavy hot ডেটা, expensive computations, repeated API রেসপন্স.
- Business value কোথায় বেশি? → এটি lowers ল্যাটেন্সি, কমায় ডাটাবেজ/origin লোড, এবং উন্নত করে থ্রুপুট.
- কোন data cache করবেন, কোনটা করবেন না (personalized/sensitive/rapidly-changing data)?
- TTL, invalidation, cache key design, এবং stale-data tolerance কতটা?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Highly dynamic ডেটা সাথে low reuse অথবা correctness-sensitive paths যা পারে না tolerate staleness.
- ইন্টারভিউ রেড ফ্ল্যাগ: Adding a ক্যাশ ছাড়া defining TTL, key format, এবং ফেইলিউর behavior.
- Assuming ক্যাশ hit rates will হতে high automatically.
- Ignoring ক্যাশ stampede এবং stale ডেটা problems.
- ব্যবহার করে ক্যাশ as the শুধু copy of important ডেটা.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Caching` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: hot path data identify করুন।
- ধাপ ২: cache location ঠিক করুন (client/CDN/app/DB layer)।
- ধাপ ৩: key + TTL + invalidation design করুন।
- ধাপ ৪: cache miss storm protect করুন।
- ধাপ ৫: stale/wrong-user data risk evaluate করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন data cache করবেন, কোনটা করবেন না (personalized/sensitive/rapidly-changing data)?
- TTL, invalidation, cache key design, এবং stale-data tolerance কতটা?
- cache miss/stampede হলে origin/DB-কে কীভাবে protect করবেন?

---

## এক লাইনে

- `Caching` repeated read workload দ্রুত serve করতে cache placement, TTL, invalidation, এবং freshness trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: cache key, TTL, invalidation, cache hit ratio, stale data

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Caching` cache কোথায় বসবে, কী cache হবে, আর freshness বনাম speed trade-off কীভাবে সামলাবেন—সেটা বোঝায়।

- Caching stores frequently used ডেটা in a faster layer (memory অথবা edge) to কমাতে repeated expensive কাজ.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: একই data বারবার origin/DB থেকে আনলে latency ও cost বাড়ে; cache policy ছাড়া speed ও scale ধরে রাখা কঠিন।

- এটি lowers ল্যাটেন্সি, কমায় ডাটাবেজ/origin লোড, এবং উন্নত করে থ্রুপুট.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: cache hit/miss flow, TTL/invalidation, stampede protection, এবং stale-data risk mitigation একসাথে ভাবতে হয়।

- একটি ক্যাশ সাহায্য করে শুধু যখন there হলো reuse এবং a good hit ratio.
- ক্যাশ design হলো mostly about invalidation, কনসিসটেন্সি, TTL, এবং key strategy, না just adding Redis.
- Caching পারে hide bottlenecks temporarily; আপনি still need to understand the source-of-truth পারফরম্যান্স.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Caching` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** ক্যাশগুলো product details এবং pricing-related read models to কমাতে pressure on primary ডাটাবেজগুলো সময় peaks.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Caching` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Read-heavy hot ডেটা, expensive computations, repeated API রেসপন্স.
- কখন ব্যবহার করবেন না: Highly dynamic ডেটা সাথে low reuse অথবা correctness-sensitive paths যা পারে না tolerate staleness.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What ক্যাশ ইনভ্যালিডেশন strategy would আপনি ব্যবহার জন্য এটি entity?\"
- রেড ফ্ল্যাগ: Adding a ক্যাশ ছাড়া defining TTL, key format, এবং ফেইলিউর behavior.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Caching`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming ক্যাশ hit rates will হতে high automatically.
- Ignoring ক্যাশ stampede এবং stale ডেটা problems.
- ব্যবহার করে ক্যাশ as the শুধু copy of important ডেটা.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Adding a ক্যাশ ছাড়া defining TTL, key format, এবং ফেইলিউর behavior.
- কমন ভুল এড়ান: Assuming ক্যাশ hit rates will হতে high automatically.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি lowers ল্যাটেন্সি, কমায় ডাটাবেজ/origin লোড, এবং উন্নত করে থ্রুপুট.
