# LB vs Reverse Proxy — বাংলা ব্যাখ্যা

_টপিক নম্বর: 034_

## গল্পে বুঝি

মন্টু মিয়াঁ বারবার শুনছেন "load balancer" আর "reverse proxy" - দুইটাই সামনে বসে traffic নেয়, তাই confusing লাগে। কিন্তু কাজ ও scope সবসময় এক না।

`LB vs Reverse Proxy` টপিকটা এই overlap আর পার্থক্য পরিষ্কার করে: কে traffic distribute করে, কে request transform/cache/terminate TLS করে, কে policy enforce করে।

বাস্তবে অনেক product একই component-এ দুই ধরনের কাজই করে, তাই definition context-sensitive। interview-তে rigid textbook answer-এর বদলে role-based explanation ভালো।

মন্টুর ভাষায়: “দরজা” (proxy) আর “লাইন ভাগ করা ম্যানেজার” (LB) অনেক সময় একই কাউন্টারে বসে, কিন্তু দায়িত্ব আলাদা করে ভাবতে হয়।

সহজ করে বললে `LB vs Reverse Proxy` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: A লোড ব্যালেন্সার distributes traffic across multiple backends।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix`-এর মতো সিস্টেমে `LB vs Reverse Proxy`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `LB vs Reverse Proxy` আসলে কীভাবে সাহায্য করে?

`LB vs Reverse Proxy` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- user request কোন layer দিয়ে ঢুকবে এবং কোথায় route/balance/cache/failover হবে—সেটা পরিষ্কার করে।
- routing rule, health checks, timeout/retry/fallback interaction একসাথে ভাবতে সাহায্য করে।
- latency ও uneven load-এর root cause traffic-control layer-এ আছে কি না বোঝাতে সাহায্য করে।
- coarse routing (DNS/CDN) আর fine routing (LB/Gateway) আলাদা করে explain করতে সহায়তা করে।

---

### কখন `LB vs Reverse Proxy` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → ব্যবহার LBs জন্য distribution; ব্যবহার reverse proxies জন্য policy, routing, caching, অথবা protocol handling.
- Business value কোথায় বেশি? → Interviewers test whether আপনি understand responsibilities এর বদলে ব্যবহার করে এগুলো terms interchangeably.
- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না introduce multiple প্রক্সি layers সাথে overlapping responsibilities ছাড়া a reason.
- ইন্টারভিউ রেড ফ্ল্যাগ: Answering "they হলো the same thing" ছাড়া qualifying roles.
- ব্যবহার করে the terms as synonyms in all contexts.
- Forgetting রিভার্স প্রক্সি ক্যাশগুলো পারে affect কনসিসটেন্সি এবং invalidation.
- Overloading a single প্রক্সি সাথে too many concerns.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `LB vs Reverse Proxy` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: component-এর primary role বলুন - distribute, proxy, cache, auth, rewrite?
- ধাপ ২: traffic decision per-request নাকি per-connection - সেটা বলুন।
- ধাপ ৩: TLS termination, buffering, caching, header manipulation কোথায় হচ্ছে ঠিক করুন।
- ধাপ ৪: health-based backend selection লাগলে LB role explain করুন।
- ধাপ ৫: same product একাধিক role করলে তা explicitly বলুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?
- backend fail করলে fallback/timeout/retry policy কী হবে?

---

## এক লাইনে

- `LB vs Reverse Proxy` user request কোন layer দিয়ে route, balance, cache, বা failover হবে—সেই traffic control design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: traffic distribution, request proxying, TLS termination, caching/rewrite, layer responsibility

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `LB vs Reverse Proxy` request flow, routing layer, load distribution, এবং fallback path কোথায় কাজ করবে—সেটার মূল ধারণা বোঝায়।

- একটি **load balancer** distributes ট্রাফিক জুড়ে multiple backends.
- একটি **রিভার্স প্রক্সি** sits in front of সার্ভারগুলো to handle routing, TLS termination, caching, auth, অথবা protocol translation.
- One component পারে do both roles, but the concepts হলো different.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ভুল routing/load distribution হলে latency, uneven load, failover behavior, আর user experience দ্রুত খারাপ হয়ে যায়।

- Interviewers test whether আপনি understand responsibilities এর বদলে ব্যবহার করে এগুলো terms interchangeably.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: request flow, health signals, routing rules, timeout/retry/fallback interaction একসাথে design করলেই topicটা সঠিকভাবে explain হয়।

- Reverse proxies অনেক সময় add application-aware features (header manipulation, caching, রেট লিমিটিং).
- লোড ব্যালেন্সিং focuses on target selection এবং health-aware distribution.
- Compare them explicitly: every LB-facing প্রক্সি setup হলো না automatically a full API গেটওয়ে, এবং every রিভার্স প্রক্সি হলো না a scalable LB strategy by itself.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `LB vs Reverse Proxy` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** may ব্যবহার edge proxies জন্য TLS/routing এবং separate internal লোড ব্যালেন্সিং layers জন্য সার্ভিস-টু-সার্ভিস ট্রাফিক.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `LB vs Reverse Proxy` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: ব্যবহার LBs জন্য distribution; ব্যবহার reverse proxies জন্য policy, routing, caching, অথবা protocol handling.
- কখন ব্যবহার করবেন না: করবেন না introduce multiple প্রক্সি layers সাথে overlapping responsibilities ছাড়া a reason.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"পারে NGINX হতে both a রিভার্স প্রক্সি এবং a লোড balancer?\"
- রেড ফ্ল্যাগ: Answering "they হলো the same thing" ছাড়া qualifying roles.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `LB vs Reverse Proxy`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- ব্যবহার করে the terms as synonyms in all contexts.
- Forgetting রিভার্স প্রক্সি ক্যাশগুলো পারে affect কনসিসটেন্সি এবং invalidation.
- Overloading a single প্রক্সি সাথে too many concerns.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Answering "they হলো the same thing" ছাড়া qualifying roles.
- কমন ভুল এড়ান: ব্যবহার করে the terms as synonyms in all contexts.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): Interviewers test whether আপনি understand responsibilities এর বদলে ব্যবহার করে এগুলো terms interchangeably.
