# Pull CDNs — বাংলা ব্যাখ্যা

_টপিক নম্বর: 032_

## গল্পে বুঝি

মন্টু মিয়াঁ আলাদা publish pipeline ছাড়াই CDN বসাতে চান। user যখন প্রথমবার content চাইবে, তখন CDN origin থেকে এনে cache করে রাখবে - এই মডেলই pull CDN।

`Pull CDNs` টপিকের সুবিধা হলো operational simplicity: demand আসলে content fetch হবে, আগে থেকে সব push করতে হবে না।

কিন্তু cold content-এ first request slow হতে পারে, আর sudden spike-এ origin miss বেশি হলে origin server চাপ খেতে পারে।

তাই pull CDN-এ cache key, TTL, cache-control headers, এবং origin capacity planning খুব গুরুত্বপূর্ণ।

সহজ করে বললে `Pull CDNs` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: In a pull CDN model, the CDN fetches content from the origin on ক্যাশ miss and then ক্যাশs it for future requests।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Pull CDNs`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Pull CDNs` আসলে কীভাবে সাহায্য করে?

`Pull CDNs` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- user request কোন layer দিয়ে ঢুকবে এবং কোথায় route/balance/cache/failover হবে—সেটা পরিষ্কার করে।
- routing rule, health checks, timeout/retry/fallback interaction একসাথে ভাবতে সাহায্য করে।
- latency ও uneven load-এর root cause traffic-control layer-এ আছে কি না বোঝাতে সাহায্য করে।
- coarse routing (DNS/CDN) আর fine routing (LB/Gateway) আলাদা করে explain করতে সহায়তা করে।

---

### কখন `Pull CDNs` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Web assets, APIs সাথে ক্যাশ headers, simpler CDN rollouts.
- Business value কোথায় বেশি? → এটি হলো simpler to operate কারণ content হলো fetched on demand ছাড়া a separate publish step.
- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Time-critical launches যেখানে ক্যাশ misses would overload the origin.
- ইন্টারভিউ রেড ফ্ল্যাগ: Ignoring origin shielding/rate limits যখন ব্যবহার করে a pull CDN.
- Assuming pull CDN requires no ক্যাশ-control design.
- না planning জন্য ক্যাশ warm-up on major releases.
- Forgetting ক্যাশ purge behavior এবং propagation delay.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Pull CDNs` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: user edge-এ request করল।
- ধাপ ২: cache hit হলে edge সঙ্গে সঙ্গে response দিল।
- ধাপ ৩: miss হলে CDN origin থেকে content fetch করল।
- ধাপ ৪: content cache করে future requests-এ দ্রুত serve করল।
- ধাপ ৫: hit ratio/TTL policy tune না করলে origin load আবার বেড়ে যাবে।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?
- backend fail করলে fallback/timeout/retry policy কী হবে?

---

## এক লাইনে

- `Pull CDNs` user request কোন layer দিয়ে route, balance, cache, বা failover হবে—সেই traffic control design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: cache miss, origin fetch, cache hit ratio, cold content, origin protection

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Pull CDNs` request flow, routing layer, load distribution, এবং fallback path কোথায় কাজ করবে—সেটার মূল ধারণা বোঝায়।

- In a pull CDN model, the CDN fetches content from the origin on ক্যাশ miss এবং then ক্যাশগুলো it জন্য future রিকোয়েস্টগুলো.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ভুল routing/load distribution হলে latency, uneven load, failover behavior, আর user experience দ্রুত খারাপ হয়ে যায়।

- এটি হলো simpler to operate কারণ content হলো fetched on demand ছাড়া a separate publish step.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: request flow, health signals, routing rules, timeout/retry/fallback interaction একসাথে design করলেই topicটা সঠিকভাবে explain হয়।

- এই CDN কাজ করে a রিভার্স প্রক্সি ক্যাশ in front of the origin.
- First রিকোয়েস্ট may হতে slower (ক্যাশ miss), but later রিকোয়েস্টগুলো হলো faster যদি ক্যাশ হিট রেশিও হলো good.
- Compared সাথে push CDNs, pull CDNs হলো easier to adopt but less predictable জন্য cold content এবং sudden ট্রাফিক spikes.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Pull CDNs` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** product images এবং static assets পারে হতে served মাধ্যমে pull-based CDN caching সাথে origin fallback on miss.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Pull CDNs` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Web assets, APIs সাথে ক্যাশ headers, simpler CDN rollouts.
- কখন ব্যবহার করবেন না: Time-critical launches যেখানে ক্যাশ misses would overload the origin.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি protect the origin from a ক্যাশ-miss storm?\"
- রেড ফ্ল্যাগ: Ignoring origin shielding/rate limits যখন ব্যবহার করে a pull CDN.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Pull CDNs`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming pull CDN requires no ক্যাশ-control design.
- না planning জন্য ক্যাশ warm-up on major releases.
- Forgetting ক্যাশ purge behavior এবং propagation delay.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Ignoring origin shielding/rate limits যখন ব্যবহার করে a pull CDN.
- কমন ভুল এড়ান: Assuming pull CDN requires no ক্যাশ-control design.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): এটি হলো simpler to operate কারণ content হলো fetched on demand ছাড়া a separate publish step.
