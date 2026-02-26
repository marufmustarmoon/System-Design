# Active-Passive — বাংলা ব্যাখ্যা

_টপিক নম্বর: 017_

## গল্পে বুঝি

মন্টু মিয়াঁ `active-passive` deployment model নিয়ে ভাবছেন যাতে outage impact কমানো যায়। প্রশ্ন হলো: সব node কি একসাথে traffic নেবে, নাকি কিছু standby থাকবে?

`Active-Passive` টপিকটা capacity usage, failover speed, consistency complexity, এবং operational simplicity-এর trade-off বোঝায়।

Active-active-এ utilization ও failover speed ভালো হতে পারে, কিন্তু conflict/state coordination কঠিন। Active-passive-এ simpler path হতে পারে, কিন্তু standby underutilized থাকে এবং switchover সময় লাগে।

ইন্টারভিউতে region/AZ failure scenario ধরে explain করলে concept দ্রুত পরিষ্কার হয়।

সহজ করে বললে `Active-Passive` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Active-passive means one instance/region serves traffic while another stays ready to take over।

বাস্তব উদাহরণ ভাবতে চাইলে `Uber`-এর মতো সিস্টেমে `Active-Passive`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Active-Passive` আসলে কীভাবে সাহায্য করে?

`Active-Passive` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- failure scenario ধরে detection, isolation, recovery, আর fallback behavior design করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `Active-Passive` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Stateful primary/replica setups, strict কনসিসটেন্সি paths, simpler operations টিমগুলো.
- Business value কোথায় বেশি? → এটি simplifies কনসিসটেন্সি এবং operations compared সাথে অ্যাক্টিভ-অ্যাক্টিভ, especially জন্য stateful সিস্টেমগুলো.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Ultra-low downtime requirements যেখানে failover delay হলো unacceptable এবং অ্যাক্টিভ-অ্যাক্টিভ হলো viable.
- ইন্টারভিউ রেড ফ্ল্যাগ: Forgetting to account জন্য passive capacity readiness এবং রেপ্লিকেশন lag.
- Assuming passive মানে zero খরচ.
- না testing switchover regularly.
- Ignoring configuration drift মাঝে active এবং passive environments.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Active-Passive` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Active-Passive` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: active, passive, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Active-Passive` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- অ্যাক্টিভ-প্যাসিভ মানে one instance/রিজিয়ন serves ট্রাফিক যখন/একইসাথে another stays ready to take উপর.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- এটি simplifies কনসিসটেন্সি এবং operations compared সাথে অ্যাক্টিভ-অ্যাক্টিভ, especially জন্য stateful সিস্টেমগুলো.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- এই passive side may হতে warm (running) অথবা cold (stopped until needed).
- রেপ্লিকেশন keeps passive স্টেট sufficiently current; failover promotes it যখন the active side fails.
- Compared সাথে অ্যাক্টিভ-অ্যাক্টিভ, অ্যাক্টিভ-প্যাসিভ trades lower complexity জন্য potentially higher failover time এবং unused capacity.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Active-Passive` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Uber** may keep a standby control plane component জন্য a রিজিয়ন to কমাতে complexity যখন/একইসাথে preserving recovery options.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Active-Passive` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Stateful primary/replica setups, strict কনসিসটেন্সি paths, simpler operations টিমগুলো.
- কখন ব্যবহার করবেন না: Ultra-low downtime requirements যেখানে failover delay হলো unacceptable এবং অ্যাক্টিভ-অ্যাক্টিভ হলো viable.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Would আপনি choose warm standby অথবা cold standby, এবং why?\"
- রেড ফ্ল্যাগ: Forgetting to account জন্য passive capacity readiness এবং রেপ্লিকেশন lag.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Active-Passive`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming passive মানে zero খরচ.
- না testing switchover regularly.
- Ignoring configuration drift মাঝে active এবং passive environments.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Forgetting to account জন্য passive capacity readiness এবং রেপ্লিকেশন lag.
- কমন ভুল এড়ান: Assuming passive মানে zero খরচ.
- স্কেল/রিলায়েবিলিটি আলোচনায় traffic growth, failure case, আর cost একসাথে বলুন।
- কেন দরকার (শর্ট নোট): এটি simplifies কনসিসটেন্সি এবং operations compared সাথে অ্যাক্টিভ-অ্যাক্টিভ, especially জন্য stateful সিস্টেমগুলো.
