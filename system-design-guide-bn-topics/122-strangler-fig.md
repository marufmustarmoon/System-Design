# Strangler Fig — বাংলা ব্যাখ্যা

_টপিক নম্বর: 122_

## গল্পে বুঝি

`Strangler Fig` এমন একটি system/cloud design pattern যা নির্দিষ্ট ধরনের recurring problem সমাধানে ব্যবহার করা হয়। মন্টু মিয়াঁর জন্য pattern মুখস্থ করার চেয়ে problem-fit বোঝা বেশি জরুরি।

একই pattern ভুল context-এ overengineering হয়ে যেতে পারে, আবার সঠিক context-এ maintenance burden অনেক কমিয়ে দেয়।

Pattern discussion-এ interviewer সাধারণত জানতে চায়: problem statement কী, flow কী, trade-off কী, failure case কী।

তাই `Strangler Fig` explain করার সময় components + data flow + misuse case একসাথে বললে clarity আসে।

সহজ করে বললে `Strangler Fig` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Strangler Fig is a migration pattern where new functionality gradually replaces parts of a legacy system while both run in parallel for a time।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Strangler Fig`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Strangler Fig` আসলে কীভাবে সাহায্য করে?

`Strangler Fig` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- legacy system rewrite না করে ধাপে ধাপে migration plan explain করতে সাহায্য করে।
- traffic routing, slice boundaries, dual-run validation, এবং decommission plan একসাথে discuss করতে সাহায্য করে।
- big-bang rewrite risk বনাম temporary duplication cost trade-off পরিষ্কার করে।
- modernization roadmap-কে operationally safer উপায়ে structure করতে সহায়তা করে।

---

### কখন `Strangler Fig` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Legacy modernization সাথে high uptime requirements.
- Business value কোথায় বেশি? → এটি এড়ায় risky big-bang rewrites এবং অনুমতি দেয় incremental modernization.
- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Small throwaway সিস্টেমগুলো যেখানে rewrite risk এবং migration খরচ হলো low.
- ইন্টারভিউ রেড ফ্ল্যাগ: "Rewrite everything এবং switch ট্রাফিক on launch day."
- না defining slice boundaries জন্য migration.
- Forgetting dual-run validation এবং observability.
- Leaving the strangler স্টেট permanent সাথে no decommission plan.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Strangler Fig` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: pattern যে সমস্যা solve করে সেটা পরিষ্কার করুন।
- ধাপ ২: core components/actors/flow ব্যাখ্যা করুন।
- ধাপ ৩: benefits ও costs বলুন।
- ধাপ ৪: failure/misuse cases বলুন।
- ধাপ ৫: বিকল্প pattern-এর সাথে তুলনা করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?
- কোন trade-off বা limitation জানালে উত্তর বাস্তবসম্মত হবে?

---

## এক লাইনে

- `Strangler Fig` legacy system-কে big-bang rewrite ছাড়া ধাপে ধাপে নতুন service/component দিয়ে replace করার migration pattern।
- এই টপিকে বারবার আসতে পারে: incremental migration, legacy modernization, traffic routing, dual-run validation, decommission plan

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Strangler Fig` একটি reusable design pattern, যা recurring problem সমাধানে tested architectural approach দেয়।

- Strangler Fig হলো a migration pattern যেখানে new functionality gradually replaces parts of a legacy সিস্টেম যখন/একইসাথে both run in parallel জন্য a time.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Recurring problem বারবার ad-hoc ভাবে solve না করে tested pattern ব্যবহার করলে risk কমে ও design আলোচনা স্পষ্ট হয়।

- এটি এড়ায় risky big-bang rewrites এবং অনুমতি দেয় incremental modernization.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: pattern apply করার সময় actors/flow, benefits, costs, failure cases, আর migration path একসাথে ব্যাখ্যা করতে হয়।

- ট্রাফিক হলো routed so specific endpoints/features go to new সার্ভিসগুলো, যখন/একইসাথে the rest stays on the legacy সিস্টেম.
- ডেটা synchronization এবং behavioral parity হলো the hard parts, না just routing.
- ট্রেড-অফ: safer migration এবং continuous delivery vs temporary duplication এবং integration complexity.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Strangler Fig` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon**-scale legacy commerce components হলো usually replaced incrementally behind gateways rather than rewritten all at once.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Strangler Fig` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Legacy modernization সাথে high uptime requirements.
- কখন ব্যবহার করবেন না: Small throwaway সিস্টেমগুলো যেখানে rewrite risk এবং migration খরচ হলো low.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি migrate one endpoint at a time যখন/একইসাথে keeping behavior consistent?\"
- রেড ফ্ল্যাগ: "Rewrite everything এবং switch ট্রাফিক on launch day."

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Strangler Fig`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- না defining slice boundaries জন্য migration.
- Forgetting dual-run validation এবং observability.
- Leaving the strangler স্টেট permanent সাথে no decommission plan.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: "Rewrite everything এবং switch ট্রাফিক on launch day."
- কমন ভুল এড়ান: না defining slice boundaries জন্য migration.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): এটি এড়ায় risky big-bang rewrites এবং অনুমতি দেয় incremental modernization.
