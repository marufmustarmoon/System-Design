# GraphQL — বাংলা ব্যাখ্যা

_টপিক নম্বর: 080_

## গল্পে বুঝি

মন্টু মিয়াঁর mobile app এক স্ক্রিনে একাধিক resource দরকার, আর REST endpoint বেশি chatty হয়ে যাচ্ছে। front-end টিম flexible data shape চায়।

`GraphQL` টপিকটা client-driven query model বোঝায় যেখানে client প্রয়োজনমতো fields চায়।

এতে over/under-fetching কমতে পারে, কিন্তু resolver performance, N+1 queries, authorization, caching, complexity control বড় বিষয়।

GraphQL answer ভালো করতে schema design-এর পাশাপাশি execution cost ও observability discuss করতে হয়।

সহজ করে বললে `GraphQL` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: GraphQL is a query language and API runtime where clients request exactly the fields they need from a typed schema।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix`-এর মতো সিস্টেমে `GraphQL`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `GraphQL` আসলে কীভাবে সাহায্য করে?

`GraphQL` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- client-driven field selection দিয়ে over/under-fetching সমস্যার সমাধান explain করতে সাহায্য করে।
- schema/resolver design, N+1 query risk, এবং query complexity control একসাথে ভাবতে সাহায্য করে।
- frontend flexibility বনাম backend execution cost trade-off পরিষ্কার করে।
- field-level authorization ও observability planning আলোচনায় আনতে সহায়তা করে।

---

### কখন `GraphQL` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → UI aggregation, many ক্লায়েন্ট variants, evolving frontend ডেটা needs.
- Business value কোথায় বেশি? → এটি সাহায্য করে frontend/mobile ক্লায়েন্টগুলো এড়াতে উপর-fetching এবং এর অধীনে-fetching জুড়ে multiple resources.
- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Simple APIs, internal সার্ভিস calls, অথবা workloads যেখানে query খরচ control হলো hard.
- ইন্টারভিউ রেড ফ্ল্যাগ: Adopting GraphQL ছাড়া query depth/খরচ limits এবং resolver batching.
- Assuming GraphQL automatically উন্নত করে backend পারফরম্যান্স.
- কোনো batching/caching strategy জন্য resolvers.
- Treating schema design এবং access control as afterthoughts.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `GraphQL` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: schema/types/queries/mutations define করুন।
- ধাপ ২: resolver data fetching optimize করুন (batching/caching)।
- ধাপ ৩: query complexity/depth limits দিন।
- ধাপ ৪: field-level authz বিবেচনা করুন।
- ধাপ ৫: tracing ও performance hotspots monitor করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?
- debugging/tooling/compatibility-এর দিক থেকে এই protocol বেছে নেওয়ার কারণ কী?

---

## এক লাইনে

- `GraphQL` client/service communication protocol বা API style বাছাইয়ে semantics, latency, reliability, ও compatibility trade-off বোঝায়।
- এই টপিকে বারবার আসতে পারে: schema/resolvers, N+1 queries, query complexity, field-level auth, over/under-fetching

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `GraphQL` services/clients-এর communication contract, semantics, এবং network behavior বোঝার টপিক।

- GraphQL হলো a query language এবং API runtime যেখানে ক্লায়েন্টগুলো রিকোয়েস্ট exactly the fields they need from a typed schema.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: একই communication style সব workload-এ fit করে না; latency, compatibility, reliability অনুযায়ী protocol/API design দরকার।

- এটি সাহায্য করে frontend/mobile ক্লায়েন্টগুলো এড়াতে উপর-fetching এবং এর অধীনে-fetching জুড়ে multiple resources.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: timeout, retry, idempotency, versioning, error semantics, এবং observability plan ছাড়া protocol discussion অসম্পূর্ণ থাকে।

- এই সার্ভার exposes a schema; resolvers fetch ডেটা from সার্ভিসগুলো/ডাটাবেজগুলো.
- Flexibility জন্য ক্লায়েন্টগুলো পারে create backend complexity: N+1 queries, expensive nested queries, caching difficulty, এবং অথরাইজেশন at field level.
- Compared সাথে REST, GraphQL উন্নত করে ক্লায়েন্ট efficiency; compared সাথে gRPC, it হলো usually more UI-facing এবং less ideal জন্য low-level internal RPC.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `GraphQL` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix**-style multi-device UIs পারে benefit from GraphQL to shape রেসপন্সগুলো differently জন্য TV, mobile, এবং web ক্লায়েন্টগুলো.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `GraphQL` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: UI aggregation, many ক্লায়েন্ট variants, evolving frontend ডেটা needs.
- কখন ব্যবহার করবেন না: Simple APIs, internal সার্ভিস calls, অথবা workloads যেখানে query খরচ control হলো hard.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি রোধ করতে expensive GraphQL queries from overloading the backend?\"
- রেড ফ্ল্যাগ: Adopting GraphQL ছাড়া query depth/খরচ limits এবং resolver batching.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `GraphQL`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming GraphQL automatically উন্নত করে backend পারফরম্যান্স.
- কোনো batching/caching strategy জন্য resolvers.
- Treating schema design এবং access control as afterthoughts.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Adopting GraphQL ছাড়া query depth/খরচ limits এবং resolver batching.
- কমন ভুল এড়ান: Assuming GraphQL automatically উন্নত করে backend পারফরম্যান্স.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি সাহায্য করে frontend/mobile ক্লায়েন্টগুলো এড়াতে উপর-fetching এবং এর অধীনে-fetching জুড়ে multiple resources.
