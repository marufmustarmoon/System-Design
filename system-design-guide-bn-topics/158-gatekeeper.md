# Gatekeeper — বাংলা ব্যাখ্যা

_টপিক নম্বর: 158_

## গল্পে বুঝি

মন্টু মিয়াঁর public API-তে সরাসরি সব backend expose করতে চান না। একটা front component লাগবে যা request যাচাই করে, policy apply করে, তারপর ভেতরে পাঠাবে।

`Gatekeeper` টপিকটা এই security boundary component (gateway/proxy/policy layer) নিয়ে।

এখানে authentication, authorization, validation, rate limiting, abuse protection, TLS termination - অনেক security concern কেন্দ্রীভূত হতে পারে।

তবে gatekeeper থাকলেই backend blind trust করবে না; sensitive operation-এ service-level authorization এখনও দরকার।

সহজ করে বললে `Gatekeeper` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Gatekeeper is a security pattern where a dedicated component controls and filters access to protected services/resources।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Gatekeeper`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Gatekeeper` আসলে কীভাবে সাহায্য করে?

`Gatekeeper` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- identity, trust boundary, authorization, scoped access—এসব security concern layer-by-layer explain করতে সাহায্য করে।
- authn/authz, token/session validation, abuse protection, audit logging একসাথে design করতে সহায়তা করে।
- least privilege আর blast radius কমানোর approach পরিষ্কার করে।
- public edge security আর internal defense-in-depth—দুটোই discussion-এ আনতে সাহায্য করে।

---

### কখন `Gatekeeper` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Public APIs, admin interfaces, zero-ট্রাস্ট বাউন্ডারি, partner integrations.
- Business value কোথায় বেশি? → এটি centralizes অথেন্টিকেশন, অথরাইজেশন, validation, এবং policy enforcement at a ট্রাস্ট বাউন্ডারি.
- trust boundary কোথায়, আর কোন layer-এ authn/authz check হবে?
- least privilege/scoped access কীভাবে enforce করবেন?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না rely on gatekeeper শুধু এবং skip সার্ভিস-level অথরাইজেশন জন্য sensitive operations.
- ইন্টারভিউ রেড ফ্ল্যাগ: Internal সার্ভিসগুলো trust all ট্রাফিক from the গেটওয়ে ছাড়া verifying caller identity/claims.
- Putting all authz logic শুধু at the edge.
- কোনো রেট লিমিটিং/abuse controls at the gatekeeper.
- না securing গেটওয়ে-to-সার্ভিস communication.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Gatekeeper` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: public edge-এ request receive করুন।
- ধাপ ২: authn/authz/validation/rate-limit checks করুন।
- ধাপ ৩: internal service-এ verified context/claims forward করুন।
- ধাপ ৪: backend-এ defense-in-depth checks বজায় রাখুন।
- ধাপ ৫: security logs/alerts centrally monitor করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- trust boundary কোথায়, আর কোন layer-এ authn/authz check হবে?
- least privilege/scoped access কীভাবে enforce করবেন?
- audit logging, secret handling, rate limiting - এগুলো design-এ কোথায় বসবে?

---

## এক লাইনে

- `Gatekeeper` identity, authorization, trust boundary, এবং secure access control design-এর গুরুত্বপূর্ণ টপিক।
- এই টপিকে বারবার আসতে পারে: trust boundary, authn/authz, request validation, rate limiting, defense in depth

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Gatekeeper` identity, trust boundary, authorization, বা scoped access control-এর security design ধারণা বোঝায়।

- Gatekeeper হলো a সিকিউরিটি pattern যেখানে a dedicated component controls এবং filters access to protected সার্ভিসগুলো/resources.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: স্কেল বাড়ার সাথে attack surface বাড়ে; identity, access control, আর trust boundary আগে থেকে design না করলে risk বাড়ে।

- এটি centralizes অথেন্টিকেশন, অথরাইজেশন, validation, এবং policy enforcement at a ট্রাস্ট বাউন্ডারি.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: threat model, trust boundary, token/session validation, least privilege, auditability, এবং abuse protection একসাথে বলতে হয়।

- একটি gatekeeper (API গেটওয়ে, প্রক্সি, অথবা policy সার্ভিস) validates রিকোয়েস্টগুলো আগে forwarding them to internal সার্ভিসগুলো.
- এটি কমায় repeated সিকিউরিটি code in backends, but internal সার্ভিসগুলো still need defense-in-depth এবং trust-aware অথরাইজেশন.
- Compare সাথে গেটওয়ে offloading: gatekeeper emphasizes সিকিউরিটি enforcement এবং boundary protection.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Gatekeeper` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** API front ends act as gatekeepers by terminating TLS, validating credentials, এবং applying access policies আগে internal routing.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Gatekeeper` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Public APIs, admin interfaces, zero-ট্রাস্ট বাউন্ডারি, partner integrations.
- কখন ব্যবহার করবেন না: করবেন না rely on gatekeeper শুধু এবং skip সার্ভিস-level অথরাইজেশন জন্য sensitive operations.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What checks belong at the gatekeeper vs inside the সার্ভিস?\"
- রেড ফ্ল্যাগ: Internal সার্ভিসগুলো trust all ট্রাফিক from the গেটওয়ে ছাড়া verifying caller identity/claims.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Gatekeeper`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Putting all authz logic শুধু at the edge.
- কোনো রেট লিমিটিং/abuse controls at the gatekeeper.
- না securing গেটওয়ে-to-সার্ভিস communication.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Internal সার্ভিসগুলো trust all ট্রাফিক from the গেটওয়ে ছাড়া verifying caller identity/claims.
- কমন ভুল এড়ান: Putting all authz logic শুধু at the edge.
- Security টপিকে authn, authz, least privilege, logging - এই চারটা আলাদা করে বলুন।
- কেন দরকার (শর্ট নোট): এটি centralizes অথেন্টিকেশন, অথরাইজেশন, validation, এবং policy enforcement at a ট্রাস্ট বাউন্ডারি.
