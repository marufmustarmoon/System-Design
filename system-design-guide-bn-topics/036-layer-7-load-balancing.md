# Layer 7 Load Balancing — বাংলা ব্যাখ্যা

_টপিক নম্বর: 036_

## গল্পে বুঝি

মন্টু মিয়াঁ path `/api/upload` আর `/api/feed` ভিন্ন backend-এ পাঠাতে চান, আবার header/cookie দেখে routingও দরকার। এই ধরনের HTTP-aware routing-এর জায়গা হলো Layer 7 load balancing।

`Layer 7 Load Balancing` টপিকে request-এর application-layer data (path, host, header, cookie, method) দেখে সিদ্ধান্ত নেওয়া যায়।

এতে flexibility বেশি, কিন্তু parsing/inspection cost ও complexity বাড়ে। TLS termination, header rewrite, auth offloading, observability - এগুলোও প্রায়ই এই layer-এ আসে।

যেখানে smart routing দরকার, সেখানে L7 শক্তিশালী; কিন্তু ultra-low-overhead packet forwarding-এর ক্ষেত্রে L4 বেশি উপযুক্ত হতে পারে।

সহজ করে বললে `Layer 7 Load Balancing` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Layer 7 (application-layer) লোড ব্যালেন্সিং routes traffic using HTTP-level information like path, host, headers, or cookies।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Layer 7 Load Balancing`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Layer 7 Load Balancing` আসলে কীভাবে সাহায্য করে?

`Layer 7 Load Balancing` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- user request কোন layer দিয়ে ঢুকবে এবং কোথায় route/balance/cache/failover হবে—সেটা পরিষ্কার করে।
- routing rule, health checks, timeout/retry/fallback interaction একসাথে ভাবতে সাহায্য করে।
- latency ও uneven load-এর root cause traffic-control layer-এ আছে কি না বোঝাতে সাহায্য করে।
- coarse routing (DNS/CDN) আর fine routing (LB/Gateway) আলাদা করে explain করতে সহায়তা করে।

---

### কখন `Layer 7 Load Balancing` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Web/API ট্রাফিক needing content-based routing অথবা policy enforcement.
- Business value কোথায় বেশি? → এটি সক্ষম করে smart routing, canary releases, A/B testing, এবং API-specific policies.
- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Ultra-high-থ্রুপুট simple TCP ট্রাফিক যেখানে header-aware routing হলো unnecessary.
- ইন্টারভিউ রেড ফ্ল্যাগ: Choosing L7 everywhere ছাড়া considering processing overhead.
- Assuming L7 automatically উন্নত করে পারফরম্যান্স.
- Ignoring TLS termination implications এবং certificate management.
- না planning fallback যদি rules become too complex to maintain.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Layer 7 Load Balancing` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: request receive করে HTTP-level attributes inspect করুন।
- ধাপ ২: routing rule evaluate করুন (host/path/header/cookie)।
- ধাপ ৩: policy apply করুন (rewrite, auth check, rate limit, canary split ইত্যাদি)।
- ধাপ ৪: selected backend-এ forward করুন।
- ধাপ ৫: metrics/logs-এ route-level observability রাখুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?
- backend fail করলে fallback/timeout/retry policy কী হবে?

---

## এক লাইনে

- `Layer 7 Load Balancing` user request কোন layer দিয়ে route, balance, cache, বা failover হবে—সেই traffic control design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: HTTP routing, path/host/header routing, TLS termination, canary routing, app-aware policies

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Layer 7 Load Balancing` request flow, routing layer, load distribution, এবং fallback path কোথায় কাজ করবে—সেটার মূল ধারণা বোঝায়।

- লেয়ার 7 (application-layer) লোড ব্যালেন্সিং routes ট্রাফিক ব্যবহার করে HTTP-level information like path, host, headers, অথবা cookies.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ভুল routing/load distribution হলে latency, uneven load, failover behavior, আর user experience দ্রুত খারাপ হয়ে যায়।

- এটি সক্ষম করে smart routing, canary releases, A/B testing, এবং API-specific policies.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: request flow, health signals, routing rules, timeout/retry/fallback interaction একসাথে design করলেই topicটা সঠিকভাবে explain হয়।

- এই LB terminates অথবা inspects HTTP/TLS ট্রাফিক এবং makes routing decisions based on রিকোয়েস্ট metadata.
- এটি provides rich features (auth integration, rewrites, rate limits) but adds CPU খরচ এবং complexity.
- Compared সাথে L4, L7 হলো more flexible but generally slower এবং more resource-intensive per রিকোয়েস্ট.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Layer 7 Load Balancing` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** may route `/images/*` to a static সার্ভিস এবং `/api/*` to application সার্ভিসগুলো ব্যবহার করে host/path-based L7 rules.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Layer 7 Load Balancing` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Web/API ট্রাফিক needing content-based routing অথবা policy enforcement.
- কখন ব্যবহার করবেন না: Ultra-high-থ্রুপুট simple TCP ট্রাফিক যেখানে header-aware routing হলো unnecessary.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What capabilities do আপনি gain সাথে L7 লোড ব্যালেন্সিং উপর L4?\"
- রেড ফ্ল্যাগ: Choosing L7 everywhere ছাড়া considering processing overhead.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Layer 7 Load Balancing`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming L7 automatically উন্নত করে পারফরম্যান্স.
- Ignoring TLS termination implications এবং certificate management.
- না planning fallback যদি rules become too complex to maintain.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Choosing L7 everywhere ছাড়া considering processing overhead.
- কমন ভুল এড়ান: Assuming L7 automatically উন্নত করে পারফরম্যান্স.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): এটি সক্ষম করে smart routing, canary releases, A/B testing, এবং API-specific policies.
