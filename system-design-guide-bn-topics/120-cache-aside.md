# Cache-Aside — বাংলা ব্যাখ্যা

_টপিক নম্বর: 120_

## গল্পে বুঝি

মন্টু মিয়াঁ cache বসিয়েছেন, কিন্তু শুধু cache যোগ করলেই speed/consistency ঠিক থাকে না। data read/write path-এর policy ঠিক না করলে stale data, lost updates, বা origin overload হতে পারে।

`Cache-Aside` টপিকটা cache strategy-র নির্দিষ্ট flow বোঝায়: cache miss হলে কী হবে, write করলে cache/DB কোন ক্রমে update হবে, আর freshness কীভাবে রাখা হবে।

প্রতিটি strategy-র সুবিধা আলাদা: latency, durability, write amplification, consistency risk, failure behavior - সব ভিন্ন।

ইন্টারভিউতে strategy বলার সাথে সাথে “cache failure/DB failure হলে কী হবে” ব্যাখ্যা করলে answer বাস্তবসম্মত হয়।

সহজ করে বললে `Cache-Aside` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: As a data management pattern, ক্যাশ-aside places a ক্যাশ next to the data store so the application populates it on misses and invalidates it on updates।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Cache-Aside`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Cache-Aside` আসলে কীভাবে সাহায্য করে?

`Cache-Aside` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- repeated read workload-এ latency ও origin/DB load কমানোর strategy পরিষ্কার করে।
- cache key, TTL, invalidation, miss behavior, এবং stale-data risk একসাথে discuss করতে সাহায্য করে।
- cache placement (client/CDN/app/DB layer) workload অনুযায়ী বেছে নিতে সহায়তা করে।
- cache stampede বা wrong-user cache issue-এর মতো practical সমস্যা আগে থেকেই ধরতে সাহায্য করে।

---

### কখন `Cache-Aside` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Hot reads সাথে well-defined keys এবং tolerable staleness.
- Business value কোথায় বেশি? → এটি হলো a practical way to scale read-heavy ডেটা access যখন/একইসাথে preserving a clear source of truth.
- কোন data cache করবেন, কোনটা করবেন না (personalized/sensitive/rapidly-changing data)?
- TTL, invalidation, cache key design, এবং stale-data tolerance কতটা?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: ডেটা requiring strict strong-consistent reads on every রিকোয়েস্ট.
- ইন্টারভিউ রেড ফ্ল্যাগ: Adding ক্যাশ-অ্যাসাইড ছাড়া defining fallback এবং invalidation ওনারশিপ.
- Treating ক্যাশ as source of truth.
- কোনো stampede protection on hot misses.
- কোনো মেট্রিকস on hit rate এবং stale reads.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Cache-Aside` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: read path-এ cache hit/miss flow আঁকুন।
- ধাপ ২: write path-এ DB ও cache update order নির্ধারণ করুন।
- ধাপ ৩: failure case (cache down/DB slow) behavior বলুন।
- ধাপ ৪: TTL/invalidation/refresh policy যোগ করুন।
- ধাপ ৫: duplicate writes/stale reads acceptability mention করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন data cache করবেন, কোনটা করবেন না (personalized/sensitive/rapidly-changing data)?
- TTL, invalidation, cache key design, এবং stale-data tolerance কতটা?
- cache miss/stampede হলে origin/DB-কে কীভাবে protect করবেন?

---

## এক লাইনে

- `Cache-Aside` repeated read workload দ্রুত serve করতে cache placement, TTL, invalidation, এবং freshness trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: cache miss flow, lazy loading, TTL, invalidation, stale cache

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Cache-Aside` cache কোথায় বসবে, কী cache হবে, আর freshness বনাম speed trade-off কীভাবে সামলাবেন—সেটা বোঝায়।

- As a ডেটা management pattern, ক্যাশ-অ্যাসাইড places a ক্যাশ next to the ডেটা store so the application populates it on misses এবং invalidates it on updates.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: একই data বারবার origin/DB থেকে আনলে latency ও cost বাড়ে; cache policy ছাড়া speed ও scale ধরে রাখা কঠিন।

- এটি হলো a practical way to scale read-heavy ডেটা access যখন/একইসাথে preserving a clear source of truth.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: cache hit/miss flow, TTL/invalidation, stampede protection, এবং stale-data risk mitigation একসাথে ভাবতে হয়।

- এটি pattern হলো most effective যখন ক্যাশ keys align সাথে dominant query access paths এবং invalidation ওনারশিপ হলো clear.
- In a ডেটা management discussion, the focus হলো on কনসিসটেন্সি boundaries, ক্যাশ ফেইলিউর behavior, এবং ডেটা ওনারশিপ, না just API ল্যাটেন্সি.
- Compared সাথে the earlier caching section, এটি emphasizes architectural placement এবং source-of-truth discipline.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Cache-Aside` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** catalog read models পারে ব্যবহার ক্যাশ-অ্যাসাইড at সার্ভিস boundaries to protect primary ডাটাবেজগুলো সময় ট্রাফিক spikes.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Cache-Aside` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Hot reads সাথে well-defined keys এবং tolerable staleness.
- কখন ব্যবহার করবেন না: ডেটা requiring strict strong-consistent reads on every রিকোয়েস্ট.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Who owns ক্যাশ ইনভ্যালিডেশন জন্য এটি entity এবং what happens যদি ক্যাশ হলো down?\"
- রেড ফ্ল্যাগ: Adding ক্যাশ-অ্যাসাইড ছাড়া defining fallback এবং invalidation ওনারশিপ.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Cache-Aside`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating ক্যাশ as source of truth.
- কোনো stampede protection on hot misses.
- কোনো মেট্রিকস on hit rate এবং stale reads.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Adding ক্যাশ-অ্যাসাইড ছাড়া defining fallback এবং invalidation ওনারশিপ.
- কমন ভুল এড়ান: Treating ক্যাশ as source of truth.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি হলো a practical way to scale read-heavy ডেটা access যখন/একইসাথে preserving a clear source of truth.
