# Layer 4 Load Balancing — বাংলা ব্যাখ্যা

_টপিক নম্বর: 037_

## গল্পে বুঝি

মন্টু মিয়াঁর কিছু workload-এ শুধু connection দ্রুত forward করাই মূল কাজ; HTTP path/header inspect করার দরকার নেই। এখানে Layer 4 load balancing বেশি উপযোগী।

`Layer 4 Load Balancing` টপিকে transport-layer তথ্য (IP/port/protocol) দেখে traffic distribute করা হয়, তাই overhead কম এবং throughput বেশি হতে পারে।

কিন্তু application-aware routing কম থাকে; path-based routing বা header-based decisions সাধারণত L4-এ হয় না।

তাই workload অনুযায়ী L4 বনাম L7 নির্বাচন করা গুরুত্বপূর্ণ architectural trade-off।

সহজ করে বললে `Layer 4 Load Balancing` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Layer 4 (transport-layer) লোড ব্যালেন্সিং routes traffic using IP/port and transport-level information without HTTP awareness।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Layer 4 Load Balancing`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Layer 4 Load Balancing` আসলে কীভাবে সাহায্য করে?

`Layer 4 Load Balancing` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- user request কোন layer দিয়ে ঢুকবে এবং কোথায় route/balance/cache/failover হবে—সেটা পরিষ্কার করে।
- routing rule, health checks, timeout/retry/fallback interaction একসাথে ভাবতে সাহায্য করে।
- latency ও uneven load-এর root cause traffic-control layer-এ আছে কি না বোঝাতে সাহায্য করে।
- coarse routing (DNS/CDN) আর fine routing (LB/Gateway) আলাদা করে explain করতে সহায়তা করে।

---

### কখন `Layer 4 Load Balancing` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Generic TCP/UDP সার্ভিসগুলো, very high-থ্রুপুট ট্রাফিক, simpler routing needs.
- Business value কোথায় বেশি? → এটি offers lower overhead এবং কাজ করে জন্য many protocols beyond HTTP.
- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: HTTP APIs requiring host/path routing, auth checks, অথবা header-based decisions at the edge.
- ইন্টারভিউ রেড ফ্ল্যাগ: Suggesting L4 জন্য URL path routing.
- Thinking L4 মানে "worse" এর বদলে "different ট্রেড-অফ."
- Ignoring connection draining সময় ডিপ্লয়মেন্টগুলো.
- Forgetting protocol-specific behavior (যেমন, UDP রিট্রাই/loss handling).

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Layer 4 Load Balancing` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: incoming TCP/UDP connection accept করুন।
- ধাপ ২: L4 policy অনুযায়ী backend select করুন।
- ধাপ ৩: connection forward/NAT/proxy করুন।
- ধাপ ৪: health checks অনুযায়ী unhealthy backend বাদ দিন।
- ধাপ ৫: application-aware features দরকার হলে L7 layer যোগ করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?
- backend fail করলে fallback/timeout/retry policy কী হবে?

---

## এক লাইনে

- `Layer 4 Load Balancing` user request কোন layer দিয়ে route, balance, cache, বা failover হবে—সেই traffic control design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: TCP/UDP forwarding, low overhead, connection-level balancing, health checks, L4 vs L7 trade-off

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Layer 4 Load Balancing` request flow, routing layer, load distribution, এবং fallback path কোথায় কাজ করবে—সেটার মূল ধারণা বোঝায়।

- লেয়ার 4 (transport-layer) লোড ব্যালেন্সিং routes ট্রাফিক ব্যবহার করে IP/port এবং transport-level information ছাড়া HTTP awareness.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ভুল routing/load distribution হলে latency, uneven load, failover behavior, আর user experience দ্রুত খারাপ হয়ে যায়।

- এটি offers lower overhead এবং কাজ করে জন্য many protocols beyond HTTP.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: request flow, health signals, routing rules, timeout/retry/fallback interaction একসাথে design করলেই topicটা সঠিকভাবে explain হয়।

- এই LB balances TCP/UDP connections to backends, অনেক সময় preserving protocol transparency.
- এটি হলো efficient জন্য high থ্রুপুট এবং long-lived connections but পারে না route based on paths/headers.
- Compared সাথে L7, L4 হলো simpler এবং faster but less flexible জন্য application-specific routing.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Layer 4 Load Balancing` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** infrastructure ব্যবহার করে transport-level balancing জন্য certain high-থ্রুপুট internal সার্ভিসগুলো এবং network-level ট্রাফিক handling.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Layer 4 Load Balancing` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Generic TCP/UDP সার্ভিসগুলো, very high-থ্রুপুট ট্রাফিক, simpler routing needs.
- কখন ব্যবহার করবেন না: HTTP APIs requiring host/path routing, auth checks, অথবা header-based decisions at the edge.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Why might আপনি put an L4 LB in front of L7 proxies?\"
- রেড ফ্ল্যাগ: Suggesting L4 জন্য URL path routing.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Layer 4 Load Balancing`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Thinking L4 মানে "worse" এর বদলে "different ট্রেড-অফ."
- Ignoring connection draining সময় ডিপ্লয়মেন্টগুলো.
- Forgetting protocol-specific behavior (যেমন, UDP রিট্রাই/loss handling).

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Suggesting L4 জন্য URL path routing.
- কমন ভুল এড়ান: Thinking L4 মানে "worse" এর বদলে "different ট্রেড-অফ."
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): এটি offers lower overhead এবং কাজ করে জন্য many protocols beyond HTTP.
