# Ambassador — বাংলা ব্যাখ্যা

_টপিক নম্বর: 133_

## গল্পে বুঝি

মন্টু মিয়াঁর টিম বড় হওয়ার সাথে সাথে `Ambassador`-এর মতো প্রশ্ন উঠে: সবকিছু এক service-এ রাখবেন, নাকি boundary আলাদা করবেন?

Service boundary design মানে শুধু code split না; ownership, data responsibility, deployment independence, and failure isolation ডিজাইন করা।

ভুল decomposition করলে network calls বাড়ে, debugging কঠিন হয়, আর operational overhead team capacity ছাড়িয়ে যায়।

তাই interview-তে service architecture নিয়ে কথা বললে simplicity বনাম flexibility trade-off স্পষ্ট করা জরুরি।

সহজ করে বললে `Ambassador` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Ambassador is a pattern where a helper proxy/process handles outbound connectivity concerns for an application (service discovery, retries, TLS, routing to external services)।

বাস্তব উদাহরণ ভাবতে চাইলে `Uber`-এর মতো সিস্টেমে `Ambassador`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Ambassador` আসলে কীভাবে সাহায্য করে?

`Ambassador` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- service boundary, data ownership, dependency, আর deployment independence স্পষ্ট করতে সাহায্য করে।
- microservice-style decomposition-এর benefit বনাম operational complexity trade-off বুঝতে সহায়তা করে।
- service discovery/config/retry/timeout/observability-এর operational pieces discussion-এ আনতে সাহায্য করে।
- team ownership ও blast radius অনুযায়ী architecture break-down করতে সুবিধা দেয়।

---

### কখন `Ambassador` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Standardizing outbound calls, রিট্রাইগুলো, discovery, এবং TLS জুড়ে many সার্ভিসগুলো.
- Business value কোথায় বেশি? → এটি keeps application code simpler এবং standardizes how সার্ভিসগুলো talk to external dependencies.
- service boundary business capability অনুযায়ী ঠিক করা হয়েছে কি?
- data ownership এবং API contract clear কি?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Small সিস্টেমগুলো যেখানে app-native ক্লায়েন্টগুলো হলো simpler এবং sufficient.
- ইন্টারভিউ রেড ফ্ল্যাগ: Adding an ambassador ছাড়া observability into প্রক্সি রিট্রাইগুলো/timeouts.
- Hiding রিট্রাই স্টর্মs inside the প্রক্সি.
- না aligning প্রক্সি timeout/রিট্রাই policy সাথে application semantics.
- Assuming প্রক্সি patterns remove the need জন্য আইডেমপোটেন্ট operations.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Ambassador` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: business capability map করে service boundary ভাবুন।
- ধাপ ২: data ownership ও API contracts ঠিক করুন।
- ধাপ ৩: discovery/config/retry/timeout/observability operational pieces যোগ করুন।
- ধাপ ৪: failure isolation ও dependency graph explain করুন।
- ধাপ ৫: monolith-to-service migration path থাকলে mention করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- service boundary business capability অনুযায়ী ঠিক করা হয়েছে কি?
- data ownership এবং API contract clear কি?
- service decomposition থেকে পাওয়া gain কি operational complexity justify করছে?

---

## এক লাইনে

- `Ambassador` service boundary, ownership, dependency, এবং deployment/operational complexity trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: problem fit, data flow, trade-off, failure case, migration/operations

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Ambassador` service boundary, ownership, dependency, এবং deployment independence নিয়ে service architecture-এর ধারণা বোঝায়।

- Ambassador হলো a pattern যেখানে a helper প্রক্সি/process handles outbound connectivity concerns জন্য an application (সার্ভিস ডিসকভারি, রিট্রাইগুলো, TLS, routing to external সার্ভিসগুলো).

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: টিম/সিস্টেম বড় হলে ownership, deployment, dependency, আর blast radius manage করতে পরিষ্কার service boundary দরকার।

- এটি keeps application code simpler এবং standardizes how সার্ভিসগুলো talk to external dependencies.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: service boundary, API contract, dependency failure, retries/timeouts, এবং deployment/ownership impact একসাথে explain করতে হয়।

- এই app talks to a local ambassador endpoint; the ambassador handles remote connection details এবং policies.
- এটি উন্নত করে কনসিসটেন্সি এবং portability জুড়ে সার্ভিসগুলো, but adds another component to monitor এবং debug.
- Compare সাথে sidecar: ambassador হলো a specialized sidecar role focused on outbound সার্ভিস access.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Ambassador` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Uber**-like microservices পারে ব্যবহার local proxies/ambassadors to ম্যানেজ করতে outbound ট্রাফিক policy to shared infrastructure সার্ভিসগুলো.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Ambassador` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Standardizing outbound calls, রিট্রাইগুলো, discovery, এবং TLS জুড়ে many সার্ভিসগুলো.
- কখন ব্যবহার করবেন না: Small সিস্টেমগুলো যেখানে app-native ক্লায়েন্টগুলো হলো simpler এবং sufficient.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How হলো Ambassador different from Sidecar in practice?\"
- রেড ফ্ল্যাগ: Adding an ambassador ছাড়া observability into প্রক্সি রিট্রাইগুলো/timeouts.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Ambassador`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Hiding রিট্রাই স্টর্মs inside the প্রক্সি.
- না aligning প্রক্সি timeout/রিট্রাই policy সাথে application semantics.
- Assuming প্রক্সি patterns remove the need জন্য আইডেমপোটেন্ট operations.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Adding an ambassador ছাড়া observability into প্রক্সি রিট্রাইগুলো/timeouts.
- কমন ভুল এড়ান: Hiding রিট্রাই স্টর্মs inside the প্রক্সি.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): এটি keeps application code simpler এবং standardizes how সার্ভিসগুলো talk to external dependencies.
