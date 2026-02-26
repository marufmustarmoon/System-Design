# Cache-Aside — বাংলা ব্যাখ্যা

_টপিক নম্বর: 060_

## গল্পে বুঝি

মন্টু মিয়াঁ cache বসিয়েছেন, কিন্তু শুধু cache যোগ করলেই speed/consistency ঠিক থাকে না। data read/write path-এর policy ঠিক না করলে stale data, lost updates, বা origin overload হতে পারে।

`Cache-Aside` টপিকটা cache strategy-র নির্দিষ্ট flow বোঝায়: cache miss হলে কী হবে, write করলে cache/DB কোন ক্রমে update হবে, আর freshness কীভাবে রাখা হবে।

প্রতিটি strategy-র সুবিধা আলাদা: latency, durability, write amplification, consistency risk, failure behavior - সব ভিন্ন।

ইন্টারভিউতে strategy বলার সাথে সাথে “cache failure/DB failure হলে কী হবে” ব্যাখ্যা করলে answer বাস্তবসম্মত হয়।

সহজ করে বললে `Cache-Aside` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Cache-aside (lazy loading) means the application checks the ক্যাশ first, and on a miss reads from the DB, then stores the result in ক্যাশ।

বাস্তব উদাহরণ ভাবতে চাইলে `YouTube`-এর মতো সিস্টেমে `Cache-Aside`-এর trade-off খুব স্পষ্ট দেখা যায়।

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

- কোথায়/কখন use করবেন? → Read-heavy APIs সাথে stable keys এবং moderate staleness tolerance.
- Business value কোথায় বেশি? → এটি হলো simple, widely used, এবং এড়ায় caching ডেটা যা হলো never requested.
- কোন data cache করবেন, কোনটা করবেন না (personalized/sensitive/rapidly-changing data)?
- TTL, invalidation, cache key design, এবং stale-data tolerance কতটা?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: ডেটা requiring strict freshness on every read ছাড়া strong invalidation guarantees.
- ইন্টারভিউ রেড ফ্ল্যাগ: Saying ক্যাশ-অ্যাসাইড হলো easy ছাড়া discussing invalidation on writes.
- Forgetting to invalidate/update ক্যাশ পরে ডেটা changes.
- ব্যবহার করে one global TTL জন্য everything.
- না handling ক্যাশ outages gracefully.

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

- ক্যাশ-অ্যাসাইড (lazy loading) মানে the application checks the ক্যাশ first, এবং on a miss reads from the DB, then stores the result in ক্যাশ.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: একই data বারবার origin/DB থেকে আনলে latency ও cost বাড়ে; cache policy ছাড়া speed ও scale ধরে রাখা কঠিন।

- এটি হলো simple, widely used, এবং এড়ায় caching ডেটা যা হলো never requested.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: cache hit/miss flow, TTL/invalidation, stampede protection, এবং stale-data risk mitigation একসাথে ভাবতে হয়।

- এই app owns ক্যাশ population এবং invalidation logic.
- এটি gives good control, but stale entries এবং ক্যাশ stampede on hot misses require protections (TTL jitter, রিকোয়েস্ট coalescing, locks).
- Compared সাথে রাইট-থ্রু, ক্যাশ-অ্যাসাইড হলো simpler জন্য reads but places more কনসিসটেন্সি logic in the application.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Cache-Aside` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **YouTube** video metadata APIs পারে ব্যবহার ক্যাশ-অ্যাসাইড to serve popular video details quickly যখন/একইসাথে keeping DB as source of truth.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Cache-Aside` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Read-heavy APIs সাথে stable keys এবং moderate staleness tolerance.
- কখন ব্যবহার করবেন না: ডেটা requiring strict freshness on every read ছাড়া strong invalidation guarantees.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি রোধ করতে ক্যাশ stampede জন্য a hot key?\"
- রেড ফ্ল্যাগ: Saying ক্যাশ-অ্যাসাইড হলো easy ছাড়া discussing invalidation on writes.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Cache-Aside`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Forgetting to invalidate/update ক্যাশ পরে ডেটা changes.
- ব্যবহার করে one global TTL জন্য everything.
- না handling ক্যাশ outages gracefully.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Saying ক্যাশ-অ্যাসাইড হলো easy ছাড়া discussing invalidation on writes.
- কমন ভুল এড়ান: Forgetting to invalidate/update ক্যাশ পরে ডেটা changes.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি হলো simple, widely used, এবং এড়ায় caching ডেটা যা হলো never requested.
