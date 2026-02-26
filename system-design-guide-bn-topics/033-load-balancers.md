# Load Balancers — বাংলা ব্যাখ্যা

_টপিক নম্বর: 033_

## গল্পে বুঝি

মন্টু মিয়াঁ একটার বদলে অনেক app server বসিয়েছেন। এখন user request কোন server-এ যাবে সেটা ঠিক করার জন্য সামনে load balancer দরকার।

`Load Balancers` টপিকটি শুধু traffic ভাগ করার কথা না; health check, failover, stickiness, TLS termination, এবং rollout/canary control-এর সাথেও জড়িত।

অনেক সময় bottleneck app server না, ভুল load-balancing policy বা unhealthy node handling। তাই LB design interview-তে খুব common।

ভালো উত্তর হলে আপনি LB-কে architecture diagram-এর শুধু box না দেখিয়ে request flow-এর অংশ হিসেবে ব্যাখ্যা করবেন।

সহজ করে বললে `Load Balancers` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: A লোড ব্যালেন্সার distributes incoming traffic across multiple backend instances।

বাস্তব উদাহরণ ভাবতে চাইলে `Google, Amazon`-এর মতো সিস্টেমে `Load Balancers`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Load Balancers` আসলে কীভাবে সাহায্য করে?

`Load Balancers` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- multiple backend-এ traffic evenly distribute করে capacity ও reliability বাড়ানোর core mechanism বোঝায়।
- health checks, failover, sticky session, algorithm choice—এসব একসাথে discuss করতে সাহায্য করে।
- bottleneck backend-এ নাকি balancing policy-তে—সেটা আলাদা করে diagnose করতে সহায়তা করে।
- interview diagram-এর box থেকে বের হয়ে LB-কে real request-flow component হিসেবে explain করতে সাহায্য করে।

---

### কখন `Load Balancers` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Any সার্ভিস সাথে more than one instance অথবা অ্যাভেইলেবিলিটি requirements.
- Business value কোথায় বেশি? → এটি রোধ করে single-node overload, উন্নত করে অ্যাভেইলেবিলিটি, এবং সক্ষম করে হরাইজন্টাল স্কেলিং.
- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Single-node local dev setups অথবা extremely simple internal tools যেখানে complexity হলো না justified.
- ইন্টারভিউ রেড ফ্ল্যাগ: Assuming round-robin alone হলো enough ছাড়া হেলথ চেক.
- Treating LBs as stateless in all cases (sticky sessions may change behavior).
- Ignoring TLS termination এবং connection reuse impacts.
- Forgetting LB limits (connections, bandwidth, rules, খরচ).

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Load Balancers` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: LB entry point হিসেবে traffic নেয়।
- ধাপ ২: health state দেখে candidate backend shortlist করে।
- ধাপ ৩: algorithm অনুযায়ী backend নির্বাচন করে।
- ধাপ ৪: timeout/retry/failover policy apply করে।
- ধাপ ৫: per-backend latency/error metrics monitor করে tuning করা হয়।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- entry point কোথায় হবে: DNS, CDN, LB, reverse proxy, না gateway?
- routing rule কীসের উপর: path, host, header, health, geography, weighted split?
- backend fail করলে fallback/timeout/retry policy কী হবে?

---

## এক লাইনে

- `Load Balancers` incoming traffic healthy backends-এ distribute করা, failover, আর load-spread policy design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: health checks, traffic distribution, sticky sessions, failover, load balancing algorithm

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Load Balancers` request flow, routing layer, load distribution, এবং fallback path কোথায় কাজ করবে—সেটার মূল ধারণা বোঝায়।

- একটি লোড balancer distributes incoming ট্রাফিক জুড়ে multiple backend instances.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ভুল routing/load distribution হলে latency, uneven load, failover behavior, আর user experience দ্রুত খারাপ হয়ে যায়।

- এটি রোধ করে single-node overload, উন্নত করে অ্যাভেইলেবিলিটি, এবং সক্ষম করে হরাইজন্টাল স্কেলিং.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: request flow, health signals, routing rules, timeout/retry/fallback interaction একসাথে design করলেই topicটা সঠিকভাবে explain হয়।

- লোড balancers ব্যবহার হেলথ চেক এবং routing algorithms to send রিকোয়েস্টগুলো to healthy targets.
- They পারে operate at L4 অথবা L7, each সাথে different visibility এবং overhead.
- এই লোড balancer itself পারে become a dependency, so production designs ব্যবহার managed HA LBs অথবা redundant instances.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Load Balancers` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** এবং **Amazon** place লোড balancers in front of application fleets to spread ট্রাফিক এবং route around unhealthy instances.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Load Balancers` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Any সার্ভিস সাথে more than one instance অথবা অ্যাভেইলেবিলিটি requirements.
- কখন ব্যবহার করবেন না: Single-node local dev setups অথবা extremely simple internal tools যেখানে complexity হলো না justified.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনার লোড balancer detect এবং এড়াতে unhealthy instances?\"
- রেড ফ্ল্যাগ: Assuming round-robin alone হলো enough ছাড়া হেলথ চেক.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Load Balancers`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating LBs as stateless in all cases (sticky sessions may change behavior).
- Ignoring TLS termination এবং connection reuse impacts.
- Forgetting LB limits (connections, bandwidth, rules, খরচ).

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Assuming round-robin alone হলো enough ছাড়া হেলথ চেক.
- কমন ভুল এড়ান: Treating LBs as stateless in all cases (sticky sessions may change behavior).
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): এটি রোধ করে single-node overload, উন্নত করে অ্যাভেইলেবিলিটি, এবং সক্ষম করে হরাইজন্টাল স্কেলিং.
