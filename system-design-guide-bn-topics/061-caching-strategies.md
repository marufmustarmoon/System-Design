# Caching Strategies — বাংলা ব্যাখ্যা

_টপিক নম্বর: 061_

## গল্পে বুঝি

মন্টু মিয়াঁ দেখলেন একই data বারবার request হচ্ছে। প্রতিবার origin/DB-তে যাওয়ায় latency বাড়ছে এবং backend অযথা চাপ খাচ্ছে।

`Caching Strategies` টপিকটা সেই repeated read workload optimize করার কৌশল নিয়ে।

ক্যাশ speed বাড়ায়, কিন্তু freshness/invalidation/security/personalization mismatch হলে ভুল data serve হতে পারে - তাই cache design আসলে correctness discussion-ও।

এজন্য interview-তে cache mention করলেই key, TTL, invalidation, miss behavior, stampede protection বলা উচিত।

সহজ করে বললে `Caching Strategies` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Caching strategies define where ক্যাশs live (client, CDN, server, app, DB) and how data moves through them।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix`-এর মতো সিস্টেমে `Caching Strategies`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Caching Strategies` আসলে কীভাবে সাহায্য করে?

`Caching Strategies` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- repeated read workload-এ latency ও origin/DB load কমানোর strategy পরিষ্কার করে।
- cache key, TTL, invalidation, miss behavior, এবং stale-data risk একসাথে discuss করতে সাহায্য করে।
- cache placement (client/CDN/app/DB layer) workload অনুযায়ী বেছে নিতে সহায়তা করে।
- cache stampede বা wrong-user cache issue-এর মতো practical সমস্যা আগে থেকেই ধরতে সাহায্য করে।

---

### কখন `Caching Strategies` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → যখন a single ক্যাশ layer হলো না enough to meet ল্যাটেন্সি/খরচ goals.
- Business value কোথায় বেশি? → Different layers solve different ল্যাটেন্সি এবং লোড problems.
- কোন data cache করবেন, কোনটা করবেন না (personalized/sensitive/rapidly-changing data)?
- TTL, invalidation, cache key design, এবং stale-data tolerance কতটা?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না stack multiple ক্যাশগুলো ছাড়া understanding যা one should own freshness behavior.
- ইন্টারভিউ রেড ফ্ল্যাগ: Proposing every ক্যাশ layer at once সাথে no clear reason.
- Treating all ক্যাশগুলো as interchangeable.
- কোনো invalidation ওনারশিপ per layer.
- Forgetting observability (hit ratio, evictions, stale reads).

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Caching Strategies` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Caching Strategies` repeated read workload দ্রুত serve করতে cache placement, TTL, invalidation, এবং freshness trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: cache key, TTL, invalidation, cache hit ratio, stale data

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Caching Strategies` cache কোথায় বসবে, কী cache হবে, আর freshness বনাম speed trade-off কীভাবে সামলাবেন—সেটা বোঝায়।

- Caching strategies define যেখানে ক্যাশগুলো live (ক্লায়েন্ট, CDN, সার্ভার, app, DB) এবং how ডেটা moves মাধ্যমে them.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: একই data বারবার origin/DB থেকে আনলে latency ও cost বাড়ে; cache policy ছাড়া speed ও scale ধরে রাখা কঠিন।

- Different layers solve different ল্যাটেন্সি এবং লোড problems.
- একটি multi-layer ক্যাশ strategy হলো অনেক সময় more effective than overloading one ক্যাশ tier.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: cache hit/miss flow, TTL/invalidation, stampede protection, এবং stale-data risk mitigation একসাথে ভাবতে হয়।

- ক্যাশ placement affects hit ratio, staleness, invalidation complexity, এবং খরচ.
- একটি senior design chooses ক্যাশ layers based on ডেটা ওনারশিপ এবং ট্রাফিক locality, then defines invalidation per layer.
- Compare layers explicitly: edge ক্যাশগুলো কমাতে origin bandwidth; app ক্যাশগুলো কমাতে DB calls; DB ক্যাশগুলো optimize internal query reuse.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Caching Strategies` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** combines ক্লায়েন্ট caching, CDN edge caching, এবং সার্ভিস-level caching জন্য different parts of the playback এবং metadata path.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Caching Strategies` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: যখন a single ক্যাশ layer হলো না enough to meet ল্যাটেন্সি/খরচ goals.
- কখন ব্যবহার করবেন না: করবেন না stack multiple ক্যাশগুলো ছাড়া understanding যা one should own freshness behavior.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"যা ক্যাশ layer would আপনি add first, এবং why?\"
- রেড ফ্ল্যাগ: Proposing every ক্যাশ layer at once সাথে no clear reason.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Caching Strategies`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating all ক্যাশগুলো as interchangeable.
- কোনো invalidation ওনারশিপ per layer.
- Forgetting observability (hit ratio, evictions, stale reads).

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Proposing every ক্যাশ layer at once সাথে no clear reason.
- কমন ভুল এড়ান: Treating all ক্যাশগুলো as interchangeable.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): Different layers solve different ল্যাটেন্সি এবং লোড problems.
