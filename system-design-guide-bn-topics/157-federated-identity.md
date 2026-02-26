# Federated Identity — বাংলা ব্যাখ্যা

_টপিক নম্বর: 157_

## গল্পে বুঝি

মন্টু মিয়াঁ চান ইউজারদের password নিজে store না করে trusted identity provider (IdP) দিয়ে login করাতে। এতে security risk ও account management burden কমে।

`Federated Identity` টপিকটা external IdP trust করে authentication করা এবং token/claims-based identity flow বোঝায়।

কিন্তু IdP ব্যবহার করলেই কাজ শেষ না - token signature, audience, expiry, issuer validation, claims mapping, and authorization এখনও আপনার দায়িত্ব।

SSO, enterprise integration, partner access - এসব use-case-এ এই pattern খুব common।

সহজ করে বললে `Federated Identity` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Federated identity lets applications trust an external identity provider (IdP) for authentication instead of managing user credentials directly।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Federated Identity`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Federated Identity` আসলে কীভাবে সাহায্য করে?

`Federated Identity` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- identity, trust boundary, authorization, scoped access—এসব security concern layer-by-layer explain করতে সাহায্য করে।
- authn/authz, token/session validation, abuse protection, audit logging একসাথে design করতে সহায়তা করে।
- least privilege আর blast radius কমানোর approach পরিষ্কার করে।
- public edge security আর internal defense-in-depth—দুটোই discussion-এ আনতে সাহায্য করে।

---

### কখন `Federated Identity` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Enterprise সিস্টেমগুলো, multi-app ecosystems, SSO, partner integrations.
- Business value কোথায় বেশি? → এটি centralizes অথেন্টিকেশন, উন্নত করে সিকিউরিটি posture, এবং সক্ষম করে SSO জুড়ে সিস্টেমগুলো.
- trust boundary কোথায়, আর কোন layer-এ authn/authz check হবে?
- least privilege/scoped access কীভাবে enforce করবেন?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Tiny standalone prototypes যেখানে IdP integration overhead হলো না justified.
- ইন্টারভিউ রেড ফ্ল্যাগ: Trusting টোকেনগুলো ছাড়া verifying signature, audience, এবং expiry.
- Confusing অথেন্টিকেশন (who) সাথে অথরাইজেশন (what পারে they do).
- Storing sensitive claims ছাড়া need.
- কোনো টোকেন revocation/rotation strategy যেখানে required.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Federated Identity` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: user/cliente IdP-তে authenticate করে token পায়।
- ধাপ ২: application/service token validate করে (sig/issuer/audience/expiry)।
- ধাপ ৩: claims থেকে local authorization model map করে।
- ধাপ ৪: token refresh/revocation/session policy define করে।
- ধাপ ৫: audit logs ও failure handling যোগ করে।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- trust boundary কোথায়, আর কোন layer-এ authn/authz check হবে?
- least privilege/scoped access কীভাবে enforce করবেন?
- audit logging, secret handling, rate limiting - এগুলো design-এ কোথায় বসবে?

---

## এক লাইনে

- `Federated Identity` identity, authorization, trust boundary, এবং secure access control design-এর গুরুত্বপূর্ণ টপিক।
- এই টপিকে বারবার আসতে পারে: IdP, tokens/claims, SSO, token validation, authn vs authz

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Federated Identity` identity, trust boundary, authorization, বা scoped access control-এর security design ধারণা বোঝায়।

- Federated identity lets applications trust an external identity provider (IdP) জন্য অথেন্টিকেশন এর বদলে managing ইউজার credentials directly.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: স্কেল বাড়ার সাথে attack surface বাড়ে; identity, access control, আর trust boundary আগে থেকে design না করলে risk বাড়ে।

- এটি centralizes অথেন্টিকেশন, উন্নত করে সিকিউরিটি posture, এবং সক্ষম করে SSO জুড়ে সিস্টেমগুলো.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: threat model, trust boundary, token/session validation, least privilege, auditability, এবং abuse protection একসাথে বলতে হয়।

- ক্লায়েন্টগুলো authenticate সাথে an IdP এবং receive টোকেনগুলো/assertions used by সার্ভিসগুলো জন্য identity এবং claims.
- Federation কমায় password handling in আপনার app, but টোকেন validation, trust config, এবং অথরাইজেশন mapping remain আপনার responsibility.
- Compare সাথে local auth: federation উন্নত করে central control এবং ইউজার experience, but adds dependency on identity infrastructure.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Federated Identity` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** enterprise/internal সিস্টেমগুলো অনেক সময় ব্যবহার federated identity so employees এবং partner apps authenticate মাধ্যমে centralized identity providers.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Federated Identity` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Enterprise সিস্টেমগুলো, multi-app ecosystems, SSO, partner integrations.
- কখন ব্যবহার করবেন না: Tiny standalone prototypes যেখানে IdP integration overhead হলো না justified.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What do আপনি validate in a federated identity টোকেন আগে accepting it?\"
- রেড ফ্ল্যাগ: Trusting টোকেনগুলো ছাড়া verifying signature, audience, এবং expiry.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Federated Identity`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Confusing অথেন্টিকেশন (who) সাথে অথরাইজেশন (what পারে they do).
- Storing sensitive claims ছাড়া need.
- কোনো টোকেন revocation/rotation strategy যেখানে required.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Trusting টোকেনগুলো ছাড়া verifying signature, audience, এবং expiry.
- কমন ভুল এড়ান: Confusing অথেন্টিকেশন (who) সাথে অথরাইজেশন (what পারে they do).
- Security টপিকে authn, authz, least privilege, logging - এই চারটা আলাদা করে বলুন।
- কেন দরকার (শর্ট নোট): এটি centralizes অথেন্টিকেশন, উন্নত করে সিকিউরিটি posture, এবং সক্ষম করে SSO জুড়ে সিস্টেমগুলো.
