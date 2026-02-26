# Anti-Corruption Layer — বাংলা ব্যাখ্যা

_টপিক নম্বর: 132_

## গল্পে বুঝি

মন্টু মিয়াঁর টিম বড় হওয়ার সাথে সাথে `Anti-Corruption Layer`-এর মতো প্রশ্ন উঠে: সবকিছু এক service-এ রাখবেন, নাকি boundary আলাদা করবেন?

Service boundary design মানে শুধু code split না; ownership, data responsibility, deployment independence, and failure isolation ডিজাইন করা।

ভুল decomposition করলে network calls বাড়ে, debugging কঠিন হয়, আর operational overhead team capacity ছাড়িয়ে যায়।

তাই interview-তে service architecture নিয়ে কথা বললে simplicity বনাম flexibility trade-off স্পষ্ট করা জরুরি।

সহজ করে বললে `Anti-Corruption Layer` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: An Anti-Corruption Layer (ACL) isolates your domain model from a legacy/external system by translating data and behaviors at the boundary।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Anti-Corruption Layer`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Anti-Corruption Layer` আসলে কীভাবে সাহায্য করে?

`Anti-Corruption Layer` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- service boundary, data ownership, dependency, আর deployment independence স্পষ্ট করতে সাহায্য করে।
- microservice-style decomposition-এর benefit বনাম operational complexity trade-off বুঝতে সহায়তা করে।
- service discovery/config/retry/timeout/observability-এর operational pieces discussion-এ আনতে সাহায্য করে।
- team ownership ও blast radius অনুযায়ী architecture break-down করতে সুবিধা দেয়।

---

### কখন `Anti-Corruption Layer` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Legacy integration, third-party APIs সাথে awkward schemas, domain migrations.
- Business value কোথায় বেশি? → এটি রোধ করে legacy অথবা third-party models from leaking into আপনার new সার্ভিসগুলো এবং spreading coupling.
- service boundary business capability অনুযায়ী ঠিক করা হয়েছে কি?
- data ownership এবং API contract clear কি?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Internal greenfield সিস্টেমগুলো সাথে no incompatible boundary to protect.
- ইন্টারভিউ রেড ফ্ল্যাগ: Letting legacy DTOs become আপনার new সার্ভিস’s internal model.
- Building a thin প্রক্সি এবং calling it an ACL ছাড়া translation semantics.
- কোনো tests জন্য mapping edge cases.
- Putting business logic unrelated to translation into the ACL.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Anti-Corruption Layer` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Anti-Corruption Layer` service boundary, ownership, dependency, এবং deployment/operational complexity trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: anti, corruption, layer, use case, trade-off

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Anti-Corruption Layer` service boundary, ownership, dependency, এবং deployment independence নিয়ে service architecture-এর ধারণা বোঝায়।

- একটি Anti-Corruption Layer (ACL) isolates আপনার domain model from a legacy/external সিস্টেম by translating ডেটা এবং behaviors at the boundary.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: টিম/সিস্টেম বড় হলে ownership, deployment, dependency, আর blast radius manage করতে পরিষ্কার service boundary দরকার।

- এটি রোধ করে legacy অথবা third-party models from leaking into আপনার new সার্ভিসগুলো এবং spreading coupling.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: service boundary, API contract, dependency failure, retries/timeouts, এবং deployment/ownership impact একসাথে explain করতে হয়।

- এই ACL maps রিকোয়েস্টগুলো/রেসপন্সগুলো, error models, এবং semantics মাঝে সিস্টেমগুলো.
- এটি adds an integration layer এবং some ল্যাটেন্সি, but preserves internal model quality এবং migration flexibility.
- Compare সাথে direct integration: direct calls হলো simpler now; ACL lowers long-term coupling এবং migration risk.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Anti-Corruption Layer` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon**-style modernization projects অনেক সময় place ACLs মাঝে new সার্ভিসগুলো এবং legacy order/account সিস্টেমগুলো সময় migration.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Anti-Corruption Layer` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Legacy integration, third-party APIs সাথে awkward schemas, domain migrations.
- কখন ব্যবহার করবেন না: Internal greenfield সিস্টেমগুলো সাথে no incompatible boundary to protect.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What would আপনার anti-corruption layer translate in এটি migration?\"
- রেড ফ্ল্যাগ: Letting legacy DTOs become আপনার new সার্ভিস’s internal model.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Anti-Corruption Layer`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Building a thin প্রক্সি এবং calling it an ACL ছাড়া translation semantics.
- কোনো tests জন্য mapping edge cases.
- Putting business logic unrelated to translation into the ACL.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Letting legacy DTOs become আপনার new সার্ভিস’s internal model.
- কমন ভুল এড়ান: Building a thin প্রক্সি এবং calling it an ACL ছাড়া translation semantics.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): এটি রোধ করে legacy অথবা third-party models from leaking into আপনার new সার্ভিসগুলো এবং spreading coupling.
