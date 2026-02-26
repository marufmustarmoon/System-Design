# Service Discovery — বাংলা ব্যাখ্যা

_টপিক নম্বর: 041_

## গল্পে বুঝি

মন্টু মিয়াঁর টিম বড় হওয়ার সাথে সাথে `Service Discovery`-এর মতো প্রশ্ন উঠে: সবকিছু এক service-এ রাখবেন, নাকি boundary আলাদা করবেন?

Service boundary design মানে শুধু code split না; ownership, data responsibility, deployment independence, and failure isolation ডিজাইন করা।

ভুল decomposition করলে network calls বাড়ে, debugging কঠিন হয়, আর operational overhead team capacity ছাড়িয়ে যায়।

তাই interview-তে service architecture নিয়ে কথা বললে simplicity বনাম flexibility trade-off স্পষ্ট করা জরুরি।

সহজ করে বললে `Service Discovery` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Service discovery is the mechanism services use to find the network location of other services dynamically।

বাস্তব উদাহরণ ভাবতে চাইলে `Uber`-এর মতো সিস্টেমে `Service Discovery`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Service Discovery` আসলে কীভাবে সাহায্য করে?

`Service Discovery` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- dynamic service endpoints/instances runtime-এ খুঁজে পাওয়ার problemটি কীভাবে solve হবে—সেটা পরিষ্কার করে।
- registration, health, deregistration, আর stale endpoint risk discussion-এ আনতে সাহায্য করে।
- client-side বনাম server-side discovery trade-off explain করতে সহায়তা করে।
- autoscaling ও ephemeral instances-এর environment-এ routing reliability বাড়াতে সাহায্য করে।

---

### কখন `Service Discovery` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Dynamic infrastructure, microservices, container orchestration.
- Business value কোথায় বেশি? → In modern ডিপ্লয়মেন্টগুলো, instances come এবং go due to autoscaling, ফেইলিউরগুলো, এবং rolling ডিপ্লয়মেন্টগুলো.
- service boundary business capability অনুযায়ী ঠিক করা হয়েছে কি?
- data ownership এবং API contract clear কি?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Small static ডিপ্লয়মেন্টগুলো সাথে fixed endpoints এবং low change frequency.
- ইন্টারভিউ রেড ফ্ল্যাগ: Hardcoding সার্ভিস IPs in a microservice design.
- Ignoring stale registry entries এবং health propagation delays.
- Treating discovery as sufficient ছাড়া রিট্রাইগুলো/timeouts.
- Forgetting DNS/সার্ভিস mesh capabilities already provided by the platform.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Service Discovery` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Service Discovery` service boundary, ownership, dependency, এবং deployment/operational complexity trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: service registry, instance health, dynamic endpoints, client/server-side discovery, registration

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Service Discovery` service boundary, ownership, dependency, এবং deployment independence নিয়ে service architecture-এর ধারণা বোঝায়।

- সার্ভিস ডিসকভারি হলো the mechanism সার্ভিসগুলো ব্যবহার to find the network location of other সার্ভিসগুলো dynamically.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: টিম/সিস্টেম বড় হলে ownership, deployment, dependency, আর blast radius manage করতে পরিষ্কার service boundary দরকার।

- In modern ডিপ্লয়মেন্টগুলো, instances come এবং go due to autoscaling, ফেইলিউরগুলো, এবং rolling ডিপ্লয়মেন্টগুলো.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: service boundary, API contract, dependency failure, retries/timeouts, এবং deployment/ownership impact একসাথে explain করতে হয়।

- একটি registry (অথবা platform DNS) tracks healthy সার্ভিস instances; ক্লায়েন্টগুলো অথবা sidecars resolve names to endpoints.
- Discovery হলো tied to হেলথ চেক, লোড ব্যালেন্সিং, এবং instance lifecycle.
- Compare approaches: ক্লায়েন্ট-side discovery gives more control; সার্ভার-side discovery হলো simpler জন্য app code.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Service Discovery` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Uber**-style microservice fleets rely on সার্ভিস ডিসকভারি কারণ instance IPs change frequently সময় autoscaling.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Service Discovery` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Dynamic infrastructure, microservices, container orchestration.
- কখন ব্যবহার করবেন না: Small static ডিপ্লয়মেন্টগুলো সাথে fixed endpoints এবং low change frequency.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Would আপনি ব্যবহার ক্লায়েন্ট-side অথবা সার্ভার-side সার্ভিস ডিসকভারি here?\"
- রেড ফ্ল্যাগ: Hardcoding সার্ভিস IPs in a microservice design.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Service Discovery`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Ignoring stale registry entries এবং health propagation delays.
- Treating discovery as sufficient ছাড়া রিট্রাইগুলো/timeouts.
- Forgetting DNS/সার্ভিস mesh capabilities already provided by the platform.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Hardcoding সার্ভিস IPs in a microservice design.
- কমন ভুল এড়ান: Ignoring stale registry entries এবং health propagation delays.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): In modern ডিপ্লয়মেন্টগুলো, instances come এবং go due to autoscaling, ফেইলিউরগুলো, এবং rolling ডিপ্লয়মেন্টগুলো.
