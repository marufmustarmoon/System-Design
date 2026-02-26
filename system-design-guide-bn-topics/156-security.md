# Security — বাংলা ব্যাখ্যা

_টপিক নম্বর: 156_

## গল্পে বুঝি

মন্টু মিয়াঁর system internet-facing হওয়ার সাথে সাথে security design আলাদা chapter হয়ে গেছে। শুধু login screen থাকলেই নিরাপত্তা সম্পূর্ণ হয় না।

`Security` টপিকটি identity, access control, trust boundary, বা scoped permission নিয়ে security architecture-র গুরুত্বপূর্ণ অংশ।

Security design-এ threat model, least privilege, monitoring, audit trail, এবং incident response readiness - সবকিছু layeredভাবে ভাবতে হয়।

ইন্টারভিউতে “TLS + auth আছে” বলার চেয়ে boundary-by-boundary controls explain করলে বেশি score পাওয়া যায়।

সহজ করে বললে `Security` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Security patterns protect identity, access, data, and system boundaries in distributed architectures।

বাস্তব উদাহরণ ভাবতে চাইলে `Google, Amazon`-এর মতো সিস্টেমে `Security`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Security` আসলে কীভাবে সাহায্য করে?

`Security` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- identity, trust boundary, authorization, scoped access—এসব security concern layer-by-layer explain করতে সাহায্য করে।
- authn/authz, token/session validation, abuse protection, audit logging একসাথে design করতে সহায়তা করে।
- least privilege আর blast radius কমানোর approach পরিষ্কার করে।
- public edge security আর internal defense-in-depth—দুটোই discussion-এ আনতে সাহায্য করে।

---

### কখন `Security` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → সবসময় জন্য production সিস্টেমগুলো, especially internet-facing এবং ডেটা-sensitive সার্ভিসগুলো.
- Business value কোথায় বেশি? → Scalable সিস্টেমগুলো become attack surfaces; সিকিউরিটি must হতে built into the design, না added later.
- trust boundary কোথায়, আর কোন layer-এ authn/authz check হবে?
- least privilege/scoped access কীভাবে enforce করবেন?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না bolt on generic controls ছাড়া understanding threat model এবং ট্রাস্ট বাউন্ডারি.
- ইন্টারভিউ রেড ফ্ল্যাগ: Auth/Authz ছাড়া discussion জন্য a public API.
- Treating TLS as the full সিকিউরিটি story.
- Ignoring internal সার্ভিস-টু-সার্ভিস অথরাইজেশন.
- কোনো অডিট লগিং অথবা secret-management plan.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Security` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: asset ও trust boundary identify করুন।
- ধাপ ২: authn/authz flow ডিজাইন করুন।
- ধাপ ৩: scoped access ও secret management নিশ্চিত করুন।
- ধাপ ৪: abuse detection/rate limiting/logging যুক্ত করুন।
- ধাপ ৫: auditability ও incident response plan উল্লেখ করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- trust boundary কোথায়, আর কোন layer-এ authn/authz check হবে?
- least privilege/scoped access কীভাবে enforce করবেন?
- audit logging, secret handling, rate limiting - এগুলো design-এ কোথায় বসবে?

---

## এক লাইনে

- `Security` identity, authorization, trust boundary, এবং secure access control design-এর গুরুত্বপূর্ণ টপিক।
- এই টপিকে বারবার আসতে পারে: authn/authz, trust boundary, least privilege, token scope, audit logs

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Security` identity, trust boundary, authorization, বা scoped access control-এর security design ধারণা বোঝায়।

- সিকিউরিটি patterns protect identity, access, ডেটা, এবং সিস্টেম boundaries in ডিস্ট্রিবিউটেড আর্কিটেকচার.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: স্কেল বাড়ার সাথে attack surface বাড়ে; identity, access control, আর trust boundary আগে থেকে design না করলে risk বাড়ে।

- Scalable সিস্টেমগুলো become attack surfaces; সিকিউরিটি must হতে built into the design, না added later.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: threat model, trust boundary, token/session validation, least privilege, auditability, এবং abuse protection একসাথে বলতে হয়।

- সিকিউরিটি patterns should হতে layered: identity, গেটওয়ে enforcement, scoped access, মনিটরিং, এবং least privilege (ন্যূনতম অনুমতি).
- এই best interview answers tie সিকিউরিটি controls to specific threats এবং ডেটা sensitivity.
- সিকিউরিটি ট্রেড-অফ include ল্যাটেন্সি, complexity, developer experience, এবং operational overhead.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Security` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** এবং **Amazon** architectures combine identity federation, gateways, scoped credentials, এবং অডিট লগিং to secure large ecosystems.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Security` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: সবসময় জন্য production সিস্টেমগুলো, especially internet-facing এবং ডেটা-sensitive সার্ভিসগুলো.
- কখন ব্যবহার করবেন না: করবেন না bolt on generic controls ছাড়া understanding threat model এবং ট্রাস্ট বাউন্ডারি.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What হলো the main ট্রাস্ট বাউন্ডারি এবং সিকিউরিটি controls in আপনার design?\"
- রেড ফ্ল্যাগ: Auth/Authz ছাড়া discussion জন্য a public API.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Security`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating TLS as the full সিকিউরিটি story.
- Ignoring internal সার্ভিস-টু-সার্ভিস অথরাইজেশন.
- কোনো অডিট লগিং অথবা secret-management plan.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Auth/Authz ছাড়া discussion জন্য a public API.
- কমন ভুল এড়ান: Treating TLS as the full সিকিউরিটি story.
- Security টপিকে authn, authz, least privilege, logging - এই চারটা আলাদা করে বলুন।
- কেন দরকার (শর্ট নোট): Scalable সিস্টেমগুলো become attack surfaces; সিকিউরিটি must হতে built into the design, না added later.
