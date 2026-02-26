# Push CDNs — বাংলা ব্যাখ্যা

_টপিক নম্বর: 031_

## গল্পে বুঝি

মন্টু মিয়াঁ নতুন ভিডিও সিরিজ রিলিজের আগেই জানেন কোন বড় ফাইলগুলো edge-এ রাখতে হবে। peak time-এ origin server বাঁচাতে তিনি আগেই content CDN-এ push করতে চান।

`Push CDNs` টপিকে এই proactive publishing model-টাই মূল ধারণা। content request আসার আগেই distribution/storage endpoint-এ upload/replicate করা হয়।

এতে first-request miss কমে এবং launch-time predictability বাড়ে, কিন্তু content publishing pipeline, versioning, invalidation, আর storage cost manage করতে হয়।

যে workload-এ content known and planned (media assets, releases), সেখানে push model বেশি control দেয়।

সহজ করে বললে `Push CDNs` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: In a push CDN model, content is proactively uploaded or replicated to CDN edge/origin storage before users request it।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix`-এর মতো সিস্টেমে `Push CDNs`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Push CDNs` আসলে কীভাবে সাহায্য করে?

`Push CDNs` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- user request কোন layer দিয়ে ঢুকবে এবং কোথায় route/balance/cache/failover হবে—সেটা পরিষ্কার করে।
- routing rule, health checks, timeout/retry/fallback interaction একসাথে ভাবতে সাহায্য করে।
- latency ও uneven load-এর root cause traffic-control layer-এ আছে কি না বোঝাতে সাহায্য করে।
- coarse routing (DNS/CDN) আর fine routing (LB/Gateway) আলাদা করে explain করতে সহায়তা করে।

---

### কখন `Push CDNs` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Large media files, release artifacts, content libraries সাথে planned publication.
- Business value কোথায় বেশি? → এটি হলো useful যখন আপনি know what content must হতে available immediately, especially large static assets.
- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Highly dynamic content যা changes frequently এবং unpredictably.
- ইন্টারভিউ রেড ফ্ল্যাগ: Choosing push CDN ছাড়া a clear content publishing pipeline.
- Assuming push eliminates all ক্যাশ ইনভ্যালিডেশন concerns.
- Ignoring storage এবং transfer costs জন্য preloading rarely accessed content.
- Treating push as universally better than pull.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Push CDNs` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: build/publish pipeline asset bundle তৈরি করে।
- ধাপ ২: CDN distribution/origin storage-এ assets push করা হয়।
- ধাপ ৩: versioned URL/cache-control policy সেট করা হয়।
- ধাপ ৪: user request এলে edge থেকে serve হয় (origin hit কমে)।
- ধাপ ৫: content update হলে re-publish + invalidation workflow চালাতে হয়।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?
- backend fail করলে fallback/timeout/retry policy কী হবে?

---

## এক লাইনে

- `Push CDNs` user request কোন layer দিয়ে route, balance, cache, বা failover হবে—সেই traffic control design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: preload assets, publishing pipeline, versioned content, origin offload, invalidation workflow

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Push CDNs` request flow, routing layer, load distribution, এবং fallback path কোথায় কাজ করবে—সেটার মূল ধারণা বোঝায়।

- In a push CDN model, content হলো proactively uploaded অথবা replicated to CDN edge/origin storage আগে ইউজাররা রিকোয়েস্ট it.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ভুল routing/load distribution হলে latency, uneven load, failover behavior, আর user experience দ্রুত খারাপ হয়ে যায়।

- এটি হলো useful যখন আপনি know what content must হতে available immediately, especially large static assets.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: request flow, health signals, routing rules, timeout/retry/fallback interaction একসাথে design করলেই topicটা সঠিকভাবে explain হয়।

- বানানো অথবা publishing pipelines push assets to CDN storage/distribution endpoints.
- এটি gives predictable অ্যাভেইলেবিলিটি জন্য known assets but adds content management এবং ডিপ্লয়মেন্ট complexity.
- Compared সাথে pull CDNs, push কমায় first-রিকোয়েস্ট origin misses but requires explicit publishing workflows.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Push CDNs` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** pre-positions popular content closer to রিজিয়নগুলো to এড়াতে origin bottlenecks সময় peak viewing.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Push CDNs` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Large media files, release artifacts, content libraries সাথে planned publication.
- কখন ব্যবহার করবেন না: Highly dynamic content যা changes frequently এবং unpredictably.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What ট্রেড-অফ make push CDN better than pull জন্য এটি workload?\"
- রেড ফ্ল্যাগ: Choosing push CDN ছাড়া a clear content publishing pipeline.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Push CDNs`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming push eliminates all ক্যাশ ইনভ্যালিডেশন concerns.
- Ignoring storage এবং transfer costs জন্য preloading rarely accessed content.
- Treating push as universally better than pull.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Choosing push CDN ছাড়া a clear content publishing pipeline.
- কমন ভুল এড়ান: Assuming push eliminates all ক্যাশ ইনভ্যালিডেশন concerns.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): এটি হলো useful যখন আপনি know what content must হতে available immediately, especially large static assets.
