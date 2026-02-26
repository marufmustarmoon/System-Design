# Active-Active — বাংলা ব্যাখ্যা

_টপিক নম্বর: 016_

## গল্পে বুঝি

মন্টু মিয়াঁ `active-active` deployment model নিয়ে ভাবছেন যাতে outage impact কমানো যায়। প্রশ্ন হলো: সব node কি একসাথে traffic নেবে, নাকি কিছু standby থাকবে?

`Active-Active` টপিকটা capacity usage, failover speed, consistency complexity, এবং operational simplicity-এর trade-off বোঝায়।

Active-active-এ utilization ও failover speed ভালো হতে পারে, কিন্তু conflict/state coordination কঠিন। Active-passive-এ simpler path হতে পারে, কিন্তু standby underutilized থাকে এবং switchover সময় লাগে।

ইন্টারভিউতে region/AZ failure scenario ধরে explain করলে concept দ্রুত পরিষ্কার হয়।

সহজ করে বললে `Active-Active` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Active-active means multiple instances/regions serve live traffic at the same time।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Active-Active`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Active-Active` আসলে কীভাবে সাহায্য করে?

`Active-Active` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- failure scenario ধরে detection, isolation, recovery, আর fallback behavior design করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `Active-Active` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Global read-heavy সিস্টেমগুলো, stateless সার্ভিসগুলো, অথবা AP-friendly workloads.
- Business value কোথায় বেশি? → এটি উন্নত করে অ্যাভেইলেবিলিটি এবং পারে কমাতে ল্যাটেন্সি by serving ইউজাররা from multiple locations.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Strictly consistent write-heavy সিস্টেমগুলো ছাড়া a strong cross-রিজিয়ন coordination plan.
- ইন্টারভিউ রেড ফ্ল্যাগ: Proposing অ্যাক্টিভ-অ্যাক্টিভ জন্য ডাটাবেজগুলো ছাড়া addressing write conflicts.
- Assuming অ্যাক্টিভ-অ্যাক্টিভ automatically মানে better ইউজার experience.
- Forgetting uneven regional লোড এবং failover surge capacity.
- Ignoring cross-রিজিয়ন ডেটা transfer খরচ.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Active-Active` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: topology ঠিক করুন (all active vs primary+standby)।
- ধাপ ২: traffic routing ও health detection design করুন।
- ধাপ ৩: state sync/replication strategy নির্ধারণ করুন।
- ধাপ ৪: failover drills এবং failback plan define করুন।
- ধাপ ৫: cost vs resilience trade-off justify করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?
- degrade mode, failover, retry, throttling - কোনটা কখন চালু হবে?

---

## এক লাইনে

- `Active-Active` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: active, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Active-Active` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- অ্যাক্টিভ-অ্যাক্টিভ মানে multiple instances/রিজিয়নগুলো serve live ট্রাফিক at the same time.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- এটি উন্নত করে অ্যাভেইলেবিলিটি এবং পারে কমাতে ল্যাটেন্সি by serving ইউজাররা from multiple locations.
- এটি এছাড়াও ব্যবহার করে capacity more efficiently than idle standbys.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- ট্রাফিক হলো distributed জুড়ে active nodes; স্টেট হলো replicated অথবা partitioned.
- এই hard part হলো ডেটা কনসিসটেন্সি, conflict resolution, এবং ট্রাফিক rebalancing সময় partial ফেইলিউরগুলো.
- Compared সাথে অ্যাক্টিভ-প্যাসিভ, অ্যাক্টিভ-অ্যাক্টিভ উন্নত করে utilization but significantly raises operational complexity.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Active-Active` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** serves many stateless frontends from multiple রিজিয়নগুলো simultaneously to কমাতে ল্যাটেন্সি এবং survive regional issues.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Active-Active` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Global read-heavy সিস্টেমগুলো, stateless সার্ভিসগুলো, অথবা AP-friendly workloads.
- কখন ব্যবহার করবেন না: Strictly consistent write-heavy সিস্টেমগুলো ছাড়া a strong cross-রিজিয়ন coordination plan.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How do আপনি handle conflicting writes in অ্যাক্টিভ-অ্যাক্টিভ ডিপ্লয়মেন্ট?\"
- রেড ফ্ল্যাগ: Proposing অ্যাক্টিভ-অ্যাক্টিভ জন্য ডাটাবেজগুলো ছাড়া addressing write conflicts.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Active-Active`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming অ্যাক্টিভ-অ্যাক্টিভ automatically মানে better ইউজার experience.
- Forgetting uneven regional লোড এবং failover surge capacity.
- Ignoring cross-রিজিয়ন ডেটা transfer খরচ.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Proposing অ্যাক্টিভ-অ্যাক্টিভ জন্য ডাটাবেজগুলো ছাড়া addressing write conflicts.
- কমন ভুল এড়ান: Assuming অ্যাক্টিভ-অ্যাক্টিভ automatically মানে better ইউজার experience.
- স্কেল/রিলায়েবিলিটি আলোচনায় traffic growth, failure case, আর cost একসাথে বলুন।
- কেন দরকার (শর্ট নোট): এটি উন্নত করে অ্যাভেইলেবিলিটি এবং পারে কমাতে ল্যাটেন্সি by serving ইউজাররা from multiple locations.
