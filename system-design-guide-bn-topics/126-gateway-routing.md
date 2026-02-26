# Gateway Routing — বাংলা ব্যাখ্যা

_টপিক নম্বর: 126_

## গল্পে বুঝি

মন্টু মিয়াঁ `Gateway Routing` টপিকটি দিয়ে traffic entry, routing, এবং distribution layer বোঝার চেষ্টা করছেন।

এই layer ভুল হলে backend শক্তিশালী হলেও user latency, failure rate, এবং cost খারাপ হতে পারে।

Traffic control discussion-এ coarse routing (DNS/CDN/region) আর fine routing (LB/gateway/path/header) আলাদা করে ভাবা ভালো।

ভালো interview answer-এ routing decision + health signal + fallback behavior একসাথে থাকে।

সহজ করে বললে `Gateway Routing` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Gateway routing is using an API gateway/reverse proxy to route incoming requests to the correct backend service based on path, host, or rules।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Gateway Routing`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Gateway Routing` আসলে কীভাবে সাহায্য করে?

`Gateway Routing` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- user request কোন layer দিয়ে ঢুকবে এবং কোথায় route/balance/cache/failover হবে—সেটা পরিষ্কার করে।
- routing rule, health checks, timeout/retry/fallback interaction একসাথে ভাবতে সাহায্য করে।
- latency ও uneven load-এর root cause traffic-control layer-এ আছে কি না বোঝাতে সাহায্য করে।
- coarse routing (DNS/CDN) আর fine routing (LB/Gateway) আলাদা করে explain করতে সহায়তা করে।

---

### কখন `Gateway Routing` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Public/mobile APIs, microservice entry points, versioned APIs.
- Business value কোথায় বেশি? → এটি provides one entry point জন্য ক্লায়েন্টগুলো যখন/একইসাথে hiding internal সার্ভিস topology.
- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Very simple internal সিস্টেমগুলো যেখানে direct সার্ভিস access হলো enough.
- ইন্টারভিউ রেড ফ্ল্যাগ: Putting all business logic into the গেটওয়ে.
- Creating a monolithic গেটওয়ে config সাথে no ওনারশিপ boundaries.
- কোনো caching/rate-limiting/auth strategy despite adding a গেটওয়ে.
- Ignoring গেটওয়ে capacity এবং ফেইলিউর মোড.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Gateway Routing` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: user request কোথা থেকে ঢুকছে map করুন।
- ধাপ ২: routing rule ও balancing policy নির্ধারণ করুন।
- ধাপ ৩: health checks ও timeout policy যুক্ত করুন।
- ধাপ ৪: failover/degraded path ব্যাখ্যা করুন।
- ধাপ ৫: observability metrics দিয়ে tuning plan বলুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?
- backend fail করলে fallback/timeout/retry policy কী হবে?

---

## এক লাইনে

- `Gateway Routing` নির্দিষ্ট recurring architecture problem সমাধানের reusable design pattern এবং তার trade-off বোঝায়।
- এই টপিকে বারবার আসতে পারে: routing policy, health checks, timeout/retry, failover, traffic distribution

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Gateway Routing` একটি reusable design pattern, যা recurring problem সমাধানে tested architectural approach দেয়।

- গেটওয়ে routing হলো ব্যবহার করে an API গেটওয়ে/রিভার্স প্রক্সি to route incoming রিকোয়েস্টগুলো to the correct backend সার্ভিস based on path, host, অথবা rules.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Recurring problem বারবার ad-hoc ভাবে solve না করে tested pattern ব্যবহার করলে risk কমে ও design আলোচনা স্পষ্ট হয়।

- এটি provides one entry point জন্য ক্লায়েন্টগুলো যখন/একইসাথে hiding internal সার্ভিস topology.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: pattern apply করার সময় actors/flow, benefits, costs, failure cases, আর migration path একসাথে ব্যাখ্যা করতে হয়।

- এই গেটওয়ে applies routing rules, version/canary logic, এবং অনেক সময় auth অথবা রেট লিমিটিং আগে forwarding.
- Centralized routing simplifies ক্লায়েন্টগুলো, but the গেটওয়ে becomes a critical dependency requiring HA এবং observability.
- Compare সাথে direct ক্লায়েন্ট-to-সার্ভিস calls: গেটওয়ে routing উন্নত করে control এবং compatibility at the খরচ of an extra hop.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Gateway Routing` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** front-door APIs route `/cart`, `/orders`, এবং `/search` ট্রাফিক to different সার্ভিসগুলো behind a common endpoint.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Gateway Routing` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Public/mobile APIs, microservice entry points, versioned APIs.
- কখন ব্যবহার করবেন না: Very simple internal সিস্টেমগুলো যেখানে direct সার্ভিস access হলো enough.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What routing rules would live in the গেটওয়ে vs in the সার্ভিসগুলো?\"
- রেড ফ্ল্যাগ: Putting all business logic into the গেটওয়ে.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Gateway Routing`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Creating a monolithic গেটওয়ে config সাথে no ওনারশিপ boundaries.
- কোনো caching/rate-limiting/auth strategy despite adding a গেটওয়ে.
- Ignoring গেটওয়ে capacity এবং ফেইলিউর মোড.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Putting all business logic into the গেটওয়ে.
- কমন ভুল এড়ান: Creating a monolithic গেটওয়ে config সাথে no ওনারশিপ boundaries.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): এটি provides one entry point জন্য ক্লায়েন্টগুলো যখন/একইসাথে hiding internal সার্ভিস topology.
