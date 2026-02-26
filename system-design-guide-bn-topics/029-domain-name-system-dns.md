# Domain Name System (DNS) — বাংলা ব্যাখ্যা

_টপিক নম্বর: 029_

## গল্পে বুঝি

মন্টু মিয়াঁর ইউজাররা `biraltube.com` লিখে অ্যাপে ঢোকে; কেউ IP address মনে রাখে না। কিন্তু backend server/IP বদলালে user যেন কিছু না বুঝে - এর জন্য DNS দরকার।

`Domain Name System (DNS)` টপিকটা বোঝায় নাম থেকে IP resolve হওয়া, caching/TTL, এবং region/failover steering-এর সীমাবদ্ধতা।

অনেকে ধরে নেয় DNS record বদলালেই সাথে সাথে সব user নতুন server-এ চলে যাবে। বাস্তবে resolver cache, TTL, client behavior - এসব কারণে propagation instant হয় না।

তাই DNS-কে coarse-grained routing/failover-এর জন্য ব্যবহার করা হয়; per-request precise balancing-এর জন্য সাধারণত LB/CDN/Gateway লাগে।

সহজ করে বললে `Domain Name System (DNS)` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: DNS translates human-readable domain names (like example.com) into IP addresses।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix`-এর মতো সিস্টেমে `Domain Name System (DNS)`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Domain Name System (DNS)` আসলে কীভাবে সাহায্য করে?

`Domain Name System (DNS)` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- domain name → IP resolution flow, resolver caching, আর TTL impact বাস্তবভাবে বুঝতে সাহায্য করে।
- DNS-based routing/failover-এর সীমাবদ্ধতা (propagation delay, cache behavior) interview-এ explain করতে সাহায্য করে।
- coarse-grained traffic steering আর per-request balancing-এর পার্থক্য বোঝায়।
- infrastructure বদলালেও user-facing domain stable রাখার কৌশল পরিষ্কার করে।

---

### কখন `Domain Name System (DNS)` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → রিজিয়ন-level ট্রাফিক routing, সার্ভিস endpoints, failover steering সাথে coarse granularity.
- Business value কোথায় বেশি? → Humans remember names better than IPs, এবং operators need to change infrastructure ছাড়া changing ক্লায়েন্ট URLs.
- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Fine-grained লোড ব্যালেন্সিং অথবা instant failover requiring sub-second reaction.
- ইন্টারভিউ রেড ফ্ল্যাগ: Assuming changing a DNS record immediately reroutes all ক্লায়েন্টগুলো.
- Ignoring DNS caching এবং TTL propagation behavior.
- Treating DNS as a সিকিউরিটি mechanism by itself.
- Forgetting recursive resolver behavior পারে vary by provider.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Domain Name System (DNS)` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: user domain resolve করতে recursive resolver-এ query পাঠায়।
- ধাপ ২: resolver cached answer থাকলে সেটাই use করে, নইলে authoritative DNS থেকে উত্তর আনে।
- ধাপ ৩: TTL অনুযায়ী answer cache হয় - low TTL agility বাড়ায়, query load-ও বাড়ায়।
- ধাপ ৪: DNS-based failover করলে propagation delay মাথায় রাখতে হয়।
- ধাপ ৫: fast failover/traffic shaping দরকার হলে DNS-এর পরের layer-এ control যোগ করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?
- backend fail করলে fallback/timeout/retry policy কী হবে?

---

## এক লাইনে

- `Domain Name System (DNS)` domain name-কে IP-তে resolve করা, caching/TTL behavior, আর coarse routing/failover বোঝার টপিক।
- এই টপিকে বারবার আসতে পারে: name resolution, TTL, resolver cache, authoritative DNS, DNS failover limits

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Domain Name System (DNS)` domain name থেকে IP resolve হওয়া, caching/TTL behavior, এবং coarse traffic steering-এর ধারণা বোঝায়।

- DNS translates human-readable domain names (like `example.com`) into IP addresses.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ভুল routing/load distribution হলে latency, uneven load, failover behavior, আর user experience দ্রুত খারাপ হয়ে যায়।

- Humans remember names better than IPs, এবং operators need to change infrastructure ছাড়া changing ক্লায়েন্ট URLs.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: request flow, health signals, routing rules, timeout/retry/fallback interaction একসাথে design করলেই topicটা সঠিকভাবে explain হয়।

- DNS resolution হলো hierarchical এবং cached (resolver, recursive DNS, authoritative DNS).
- TTL controls caching duration: low TTL উন্নত করে agility but increases query লোড এবং পারে still হতে ignored by some ক্লায়েন্টগুলো.
- DNS হলো useful জন্য routing এবং failover, but it হলো না instant এবং হলো a poor fit জন্য fast per-রিকোয়েস্ট balancing.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Domain Name System (DNS)` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** ব্যবহার করে DNS এবং ট্রাফিক management to route ইউজাররা toward regional entry points আগে application-level routing takes উপর.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Domain Name System (DNS)` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: রিজিয়ন-level ট্রাফিক routing, সার্ভিস endpoints, failover steering সাথে coarse granularity.
- কখন ব্যবহার করবেন না: Fine-grained লোড ব্যালেন্সিং অথবা instant failover requiring sub-second reaction.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What হলো the limitations of DNS-based failover?\"
- রেড ফ্ল্যাগ: Assuming changing a DNS record immediately reroutes all ক্লায়েন্টগুলো.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Domain Name System (DNS)`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Ignoring DNS caching এবং TTL propagation behavior.
- Treating DNS as a সিকিউরিটি mechanism by itself.
- Forgetting recursive resolver behavior পারে vary by provider.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Assuming changing a DNS record immediately reroutes all ক্লায়েন্টগুলো.
- কমন ভুল এড়ান: Ignoring DNS caching এবং TTL propagation behavior.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): Humans remember names better than IPs, এবং operators need to change infrastructure ছাড়া changing ক্লায়েন্ট URLs.
