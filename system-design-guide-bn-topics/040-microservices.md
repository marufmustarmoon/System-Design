# Microservices — বাংলা ব্যাখ্যা

_টপিক নম্বর: 040_

## গল্পে বুঝি

মন্টু মিয়াঁর টিম বড় হওয়ার সাথে সাথে `Microservices`-এর মতো প্রশ্ন উঠে: সবকিছু এক service-এ রাখবেন, নাকি boundary আলাদা করবেন?

Service boundary design মানে শুধু code split না; ownership, data responsibility, deployment independence, and failure isolation ডিজাইন করা।

ভুল decomposition করলে network calls বাড়ে, debugging কঠিন হয়, আর operational overhead team capacity ছাড়িয়ে যায়।

তাই interview-তে service architecture নিয়ে কথা বললে simplicity বনাম flexibility trade-off স্পষ্ট করা জরুরি।

সহজ করে বললে `Microservices` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Microservices split an application into smaller services, each owning a focused business capability।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix`-এর মতো সিস্টেমে `Microservices`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Microservices` আসলে কীভাবে সাহায্য করে?

`Microservices` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- service boundary, data ownership, dependency, আর deployment independence স্পষ্ট করতে সাহায্য করে।
- distributed complexity (network calls, retries, observability, deployment coordination) কোথায় বাড়বে তা স্পষ্ট করে।
- service discovery/config/retry/timeout/observability-এর operational pieces discussion-এ আনতে সাহায্য করে।
- team ownership ও blast radius অনুযায়ী architecture break-down করতে সুবিধা দেয়।

---

### কখন `Microservices` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Large domains, টিম স্কেলিং, independently scalable components.
- Business value কোথায় বেশি? → They সাহায্য large টিমগুলো ship independently এবং scale parts of a সিস্টেম differently.
- service boundary business capability অনুযায়ী ঠিক করা হয়েছে কি?
- data ownership এবং API contract clear কি?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Small টিমগুলো/products যেখানে a modular monolith হলো simpler এবং faster.
- ইন্টারভিউ রেড ফ্ল্যাগ: Splitting by CRUD tables এর বদলে business capabilities.
- Thinking microservices automatically উন্নত করতে স্কেলেবিলিটি.
- Creating chatty সার্ভিস-টু-সার্ভিস calls.
- Sharing one ডাটাবেজ জুড়ে সার্ভিসগুলো যখন/একইসাথে claiming independence.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Microservices` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Microservices` service boundary, ownership, dependency, এবং deployment/operational complexity trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: service boundaries, data ownership, independent deployment, network calls, operational complexity

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Microservices` service boundary, ownership, dependency, এবং deployment independence নিয়ে service architecture-এর ধারণা বোঝায়।

- Microservices split an application into smaller সার্ভিসগুলো, each owning a focused business capability.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: টিম/সিস্টেম বড় হলে ownership, deployment, dependency, আর blast radius manage করতে পরিষ্কার service boundary দরকার।

- They সাহায্য large টিমগুলো ship independently এবং scale parts of a সিস্টেম differently.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: service boundary, API contract, dependency failure, retries/timeouts, এবং deployment/ownership impact একসাথে explain করতে হয়।

- Each সার্ভিস owns its ডেটা এবং API, এবং সার্ভিসগুলো communicate via HTTP/gRPC/মেসেজগুলো.
- Benefits come সাথে operational খরচ: ডিপ্লয়মেন্ট complexity, observability needs, versioning, এবং network ফেইলিউরগুলো.
- Compare সাথে a monolith: microservices পারে উন্নত করতে টিম autonomy, but premature splitting অনেক সময় creates more complexity than value.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Microservices` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** ব্যবহার করে many সার্ভিসগুলো so টিমগুলো পারে iterate independently on playback, recommendations, billing, এবং account features.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Microservices` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Large domains, টিম স্কেলিং, independently scalable components.
- কখন ব্যবহার করবেন না: Small টিমগুলো/products যেখানে a modular monolith হলো simpler এবং faster.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি define সার্ভিস boundaries জন্য এটি সিস্টেম?\"
- রেড ফ্ল্যাগ: Splitting by CRUD tables এর বদলে business capabilities.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Microservices`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Thinking microservices automatically উন্নত করতে স্কেলেবিলিটি.
- Creating chatty সার্ভিস-টু-সার্ভিস calls.
- Sharing one ডাটাবেজ জুড়ে সার্ভিসগুলো যখন/একইসাথে claiming independence.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Splitting by CRUD tables এর বদলে business capabilities.
- কমন ভুল এড়ান: Thinking microservices automatically উন্নত করতে স্কেলেবিলিটি.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): They সাহায্য large টিমগুলো ship independently এবং scale parts of a সিস্টেম differently.
