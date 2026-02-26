# Web Server Caching — বাংলা ব্যাখ্যা

_টপিক নম্বর: 064_

## গল্পে বুঝি

মন্টু মিয়াঁ দেখলেন একই data বারবার request হচ্ছে। প্রতিবার origin/DB-তে যাওয়ায় latency বাড়ছে এবং backend অযথা চাপ খাচ্ছে।

`Web Server Caching` টপিকটা সেই repeated read workload optimize করার কৌশল নিয়ে।

ক্যাশ speed বাড়ায়, কিন্তু freshness/invalidation/security/personalization mismatch হলে ভুল data serve হতে পারে - তাই cache design আসলে correctness discussion-ও।

এজন্য interview-তে cache mention করলেই key, TTL, invalidation, miss behavior, stampede protection বলা উচিত।

সহজ করে বললে `Web Server Caching` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Web server caching stores responses or fragments at the web/reverse-proxy layer (e.g., NGINX, Varnish) before the app service।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Web Server Caching`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Web Server Caching` আসলে কীভাবে সাহায্য করে?

`Web Server Caching` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- repeated read workload-এ latency ও origin/DB load কমানোর strategy পরিষ্কার করে।
- cache key, TTL, invalidation, miss behavior, এবং stale-data risk একসাথে discuss করতে সাহায্য করে।
- cache placement (client/CDN/app/DB layer) workload অনুযায়ী বেছে নিতে সহায়তা করে।
- cache stampede বা wrong-user cache issue-এর মতো practical সমস্যা আগে থেকেই ধরতে সাহায্য করে।

---

### কখন `Web Server Caching` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Hot public pages, fragment caching, origin protection.
- Business value কোথায় বেশি? → এটি absorbs repeated রিকোয়েস্টগুলো ছাড়া hitting application code অথবা the ডাটাবেজ.
- কোন data cache করবেন, কোনটা করবেন না (personalized/sensitive/rapidly-changing data)?
- TTL, invalidation, cache key design, এবং stale-data tolerance কতটা?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Highly personalized endpoints ছাড়া safe ক্যাশ partitioning.
- ইন্টারভিউ রেড ফ্ল্যাগ: Duplicating CDN এবং প্রক্সি ক্যাশ rules ছাড়া understanding ক্যাশ ওনারশিপ.
- Caching error রেসপন্সগুলো unintentionally.
- Ignoring ক্যাশ bypass জন্য auth/session cookies.
- কোনো visibility into hit/miss মেট্রিকস.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Web Server Caching` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Web Server Caching` repeated read workload দ্রুত serve করতে cache placement, TTL, invalidation, এবং freshness trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: cache key, TTL, invalidation, cache hit ratio, stale data

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Web Server Caching` cache কোথায় বসবে, কী cache হবে, আর freshness বনাম speed trade-off কীভাবে সামলাবেন—সেটা বোঝায়।

- Web সার্ভার caching stores রেসপন্সগুলো অথবা fragments at the web/reverse-প্রক্সি layer (যেমন, NGINX, Varnish) আগে the app সার্ভিস.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: একই data বারবার origin/DB থেকে আনলে latency ও cost বাড়ে; cache policy ছাড়া speed ও scale ধরে রাখা কঠিন।

- এটি absorbs repeated রিকোয়েস্টগুলো ছাড়া hitting application code অথবা the ডাটাবেজ.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: cache hit/miss flow, TTL/invalidation, stampede protection, এবং stale-data risk mitigation একসাথে ভাবতে হয়।

- Reverse proxies ক্যাশ based on URL, headers, এবং policy rules.
- এটি হলো effective জন্য read-heavy endpoints, but invalidation এবং ইউজার-specific রেসপন্সগুলো need careful controls.
- Compared সাথে CDN caching, web সার্ভার caching হলো closer to origin এবং easier to integrate সাথে app-specific invalidation hooks.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Web Server Caching` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google**-like high-ট্রাফিক web frontends may ক্যাশ public page fragments at প্রক্সি tiers to protect backend সার্ভিসগুলো.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Web Server Caching` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Hot public pages, fragment caching, origin protection.
- কখন ব্যবহার করবেন না: Highly personalized endpoints ছাড়া safe ক্যাশ partitioning.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Why ক্যাশ at the রিভার্স প্রক্সি যদি আপনি already have a CDN?\"
- রেড ফ্ল্যাগ: Duplicating CDN এবং প্রক্সি ক্যাশ rules ছাড়া understanding ক্যাশ ওনারশিপ.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Web Server Caching`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Caching error রেসপন্সগুলো unintentionally.
- Ignoring ক্যাশ bypass জন্য auth/session cookies.
- কোনো visibility into hit/miss মেট্রিকস.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Duplicating CDN এবং প্রক্সি ক্যাশ rules ছাড়া understanding ক্যাশ ওনারশিপ.
- কমন ভুল এড়ান: Caching error রেসপন্সগুলো unintentionally.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি absorbs repeated রিকোয়েস্টগুলো ছাড়া hitting application code অথবা the ডাটাবেজ.
