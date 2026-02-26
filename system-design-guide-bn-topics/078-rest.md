# REST — বাংলা ব্যাখ্যা

_টপিক নম্বর: 078_

## গল্পে বুঝি

মন্টু মিয়াঁ public API design করছেন যাতে web/mobile/partner সবাই সহজে integrate করতে পারে। resource-oriented, HTTP-based approach হিসেবে REST এখানে common choice।

`REST` টপিকটা resource modeling, verbs/status codes, statelessness, caching, এবং API evolution নিয়ে practical আলোচনা।

REST বললেই perfect API হয় না; naming, pagination, filtering, idempotency, auth, error shape ভুল হলে client pain বাড়ে।

ইন্টারভিউতে REST answer ভালো হয় যখন resource model + operational concerns (rate limit, versioning, observability) একসাথে বলেন।

সহজ করে বললে `REST` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: REST is an architectural style for resource-oriented APIs, commonly implemented over HTTP using resource URLs and standard methods।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `REST`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `REST` আসলে কীভাবে সাহায্য করে?

`REST` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- resource-oriented API design-এ endpoints, methods, status codes, আর error semantics consistent রাখতে সাহায্য করে।
- pagination/filtering/versioning/auth/idempotency নিয়ে practical API design discussion করতে সাহায্য করে।
- public API usability ও interoperability explain করতে সুবিধা দেয়।
- HTTP semantics misuse হলে client pain কোথায় বাড়ে, সেটাও পরিষ্কার করে।

---

### কখন `REST` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Public APIs, CRUD-style resources, browser/mobile integrations.
- Business value কোথায় বেশি? → এটি provides a widely understood, interoperable API style যা কাজ করে well জন্য web ক্লায়েন্টগুলো এবং external integrations.
- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: High-পারফরম্যান্স internal calls requiring strong typing/streaming যেখানে gRPC fits better.
- ইন্টারভিউ রেড ফ্ল্যাগ: Calling any JSON-উপর-HTTP API "REST" ছাড়া resource semantics.
- Designing action-heavy endpoints যা ignore HTTP semantics.
- Returning inconsistent status codes/error formats.
- না paginating list endpoints.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `REST` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: resources ও endpoints model করুন।
- ধাপ ২: methods/status/error semantics ঠিক করুন।
- ধাপ ৩: pagination/filtering/sorting design দিন।
- ধাপ ৪: auth/versioning/idempotency rules যুক্ত করুন।
- ধাপ ৫: caching ও rate limiting discuss করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?
- debugging/tooling/compatibility-এর দিক থেকে এই protocol বেছে নেওয়ার কারণ কী?

---

## এক লাইনে

- `REST` client/service communication protocol বা API style বাছাইয়ে semantics, latency, reliability, ও compatibility trade-off বোঝায়।
- এই টপিকে বারবার আসতে পারে: resource modeling, HTTP methods, status codes, pagination, versioning

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `REST` services/clients-এর communication contract, semantics, এবং network behavior বোঝার টপিক।

- REST হলো an architectural style জন্য resource-oriented APIs, commonly implemented উপর HTTP ব্যবহার করে resource URLs এবং standard methods.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: একই communication style সব workload-এ fit করে না; latency, compatibility, reliability অনুযায়ী protocol/API design দরকার।

- এটি provides a widely understood, interoperable API style যা কাজ করে well জন্য web ক্লায়েন্টগুলো এবং external integrations.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: timeout, retry, idempotency, versioning, error semantics, এবং observability plan ছাড়া protocol discussion অসম্পূর্ণ থাকে।

- REST designs model resources এবং ব্যবহার HTTP semantics (`GET`, `POST`, `PUT`, `DELETE`, status codes, caching headers).
- এটি হলো easy to adopt এবং observable, but পারে become chatty অথবা উপর/এর অধীনে-fetching জন্য complex UIs.
- Compared সাথে gRPC, REST হলো usually easier জন্য public APIs; compared সাথে GraphQL, it offers stronger cacheability by default এবং simpler operational behavior.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `REST` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** public-facing APIs এবং many partner integrations ব্যবহার REST কারণ of ecosystem compatibility এবং tooling.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `REST` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Public APIs, CRUD-style resources, browser/mobile integrations.
- কখন ব্যবহার করবেন না: High-পারফরম্যান্স internal calls requiring strong typing/streaming যেখানে gRPC fits better.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি design REST endpoints জন্য এটি resource model?\"
- রেড ফ্ল্যাগ: Calling any JSON-উপর-HTTP API "REST" ছাড়া resource semantics.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `REST`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Designing action-heavy endpoints যা ignore HTTP semantics.
- Returning inconsistent status codes/error formats.
- না paginating list endpoints.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Calling any JSON-উপর-HTTP API "REST" ছাড়া resource semantics.
- কমন ভুল এড়ান: Designing action-heavy endpoints যা ignore HTTP semantics.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): এটি provides a widely understood, interoperable API style যা কাজ করে well জন্য web ক্লায়েন্টগুলো এবং external integrations.
