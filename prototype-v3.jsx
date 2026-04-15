import { useState, useEffect, useRef, useCallback } from "react";

/* ━━━━━━━━━━━━━━━ STYLES ━━━━━━━━━━━━━━━ */
const CSS = `
@keyframes twinkle{0%{opacity:.12}100%{opacity:.85}}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-8px)}}
@keyframes wave{0%{height:3px}50%{height:var(--h)}100%{height:3px}}
@keyframes breatheCircle{0%{transform:scale(.5);box-shadow:0 0 20px rgba(129,140,248,.2)}50%{transform:scale(1);box-shadow:0 0 60px rgba(129,140,248,.5)}100%{transform:scale(.5);box-shadow:0 0 20px rgba(129,140,248,.2)}}
@keyframes popIn{0%{transform:scale(0);opacity:0}60%{transform:scale(1.15)}100%{transform:scale(1);opacity:1}}
@keyframes starBurst{0%{opacity:0;transform:translate(0,0) scale(0)}50%{opacity:1;transform:translate(var(--tx),var(--ty)) scale(1.2)}100%{opacity:0;transform:translate(var(--tx2),var(--ty2)) scale(0)}}
@keyframes confettiFall{0%{opacity:1;transform:translateY(0) rotate(0)}100%{opacity:0;transform:translateY(120px) rotate(var(--rot))}}
@keyframes shimmer{0%{background-position:-200% center}100%{background-position:200% center}}
@keyframes glow{0%,100%{filter:brightness(1) drop-shadow(0 0 8px rgba(250,204,21,.3))}50%{filter:brightness(1.2) drop-shadow(0 0 16px rgba(250,204,21,.5))}}
@keyframes fadeUp{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:translateY(0)}}
@keyframes slideRight{from{opacity:0;transform:translateX(30px)}to{opacity:1;transform:translateX(0)}}
@keyframes karaoke{0%{background-size:0% 100%}100%{background-size:100% 100%}}
@keyframes bounce{0%,100%{transform:translateY(0)}50%{transform:translateY(-6px)}}
.fadeUp{animation:fadeUp .45s ease-out both}
.d1{animation-delay:.06s}.d2{animation-delay:.12s}.d3{animation-delay:.18s}.d4{animation-delay:.24s}.d5{animation-delay:.3s}
*{-webkit-tap-highlight-color:transparent;box-sizing:border-box}
::-webkit-scrollbar{display:none}
input::placeholder{color:rgba(255,255,255,.25)}
.glass{backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px)}
`;

/* ━━━━━━━━━━━━━━━ DATA ━━━━━━━━━━━━━━━ */
const STORIES=[
  {id:"noahs-ark",title:"Noah's Ark",sub:"A promise in the rainbow",ref:"Genesis 6-9",cat:"Trust",age:"3-5",dur:8,color:"#3b82f6",emoji:"🌈",mascotReact:"Lumi splashes in a puddle! 💦",
    prayer:"Dear God, thank You for keeping us safe, just like You kept Noah safe. Help me trust You always. Amen.",
    takeaway:"God keeps His promises and protects those who trust Him.",
    verse:'"I have set my rainbow in the clouds." — Genesis 9:13',
    text:["Long ago, when the world had forgotten about God's love, there lived a kind man named Noah. Noah loved God with all his heart and tried to do what was right every single day.","One day, God spoke to Noah and said, \"I want you to build a big, big boat called an ark.\" Noah had never built a boat before, but he trusted God completely.","Noah and his family worked day after day, hammering and sawing, building the enormous ark just as God had told them. Their neighbors laughed and said, \"Why are you building a boat on dry land?\" But Noah kept working because he trusted God's plan.","When the ark was finished, God sent animals of every kind — two by two they came! Big elephants and tiny mice, tall giraffes and round little hedgehogs. Noah welcomed them all aboard.","Then the rain began to fall. It rained and rained for forty days and forty nights. But inside the ark, Noah, his family, and all the animals were safe and warm.","When the rain finally stopped, Noah sent out a dove. The dove came back with an olive branch — land was near! As they stepped off the ark, God painted the most beautiful rainbow across the sky.","\"This rainbow is my promise,\" God said. \"I will always take care of you.\" And every time you see a rainbow, remember — God keeps His promises."],
    touchElements:[{emoji:"🌧️",x:75,y:15,tap:"Pitter patter! The rain is falling!"},{emoji:"🕊️",x:20,y:25,tap:"The dove found an olive branch!"},{emoji:"🌈",x:50,y:8,tap:"God's beautiful promise!"}]},
  {id:"david-goliath",title:"David & Goliath",sub:"Courage from within",ref:"1 Samuel 17",cat:"Courage",age:"6-8",dur:10,color:"#f97316",emoji:"⚔️",mascotReact:"Lumi flexes tiny muscles! 💪",
    prayer:"Dear God, when I feel small or scared, remind me that You are with me and I can be brave. Amen.",
    takeaway:"With God's help, even the smallest person can overcome the biggest challenges.",
    verse:'"The Lord who rescued me will rescue me." — 1 Samuel 17:37',
    text:["In a green valley between two hills, two armies faced each other. The army of Israel was on one side, and the Philistines on the other. Every day, a giant named Goliath would stomp out and shout, \"Send someone to fight me!\"","All the soldiers were terrified. Nobody wanted to face the giant. Then along came David — a young shepherd boy who had come to bring lunch to his brothers.","David wasn't a soldier. He didn't wear armor or carry a sword. But David had something the soldiers didn't — he trusted God completely.","\"I'll fight the giant,\" David said. Everyone laughed. \"You're just a boy!\" But David remembered all the times God had helped him protect his sheep.","With just five smooth stones and his sling, David walked toward the giant. \"You come with a sword, but I come in the name of the Lord!\"","David placed a stone in his sling, swung it around, and let it fly. The stone struck Goliath right on his forehead, and the mighty giant fell to the ground with a tremendous crash.","That day, everyone learned that it doesn't matter how small you are — with God on your side, you can face any giant."],
    touchElements:[{emoji:"🪨",x:30,y:20,tap:"Five smooth stones from the stream!"},{emoji:"🛡️",x:70,y:18,tap:"Goliath's giant shield clangs!"},{emoji:"⭐",x:50,y:10,tap:"God's power shines bright!"}]},
  {id:"good-samaritan",title:"The Good Samaritan",sub:"Love your neighbor",ref:"Luke 10:25-37",cat:"Kindness",age:"6-8",dur:7,color:"#14b8a6",emoji:"💝",mascotReact:"Lumi gives a warm hug! 🤗",
    prayer:"Dear God, help me see when people need help and give me a kind heart to help them. Amen.",
    takeaway:"Being kind means helping everyone, even those who are different from us.",
    verse:'"Love your neighbor as yourself." — Luke 10:27',
    text:["One day, someone asked Jesus, \"Who is my neighbor?\" Jesus answered with a story.","A man was walking down a lonely road when robbers attacked him. They took everything he had and left him hurt and alone by the side of the road.","Soon, an important man came walking by. He saw the hurt man, but he crossed to the other side of the road and kept walking. Then another important man came along — and he also walked right past.","Finally, a Samaritan came along. Now, Samaritans and the hurt man's people didn't usually get along. But when the Samaritan saw the hurt man, his heart filled with compassion.","He knelt down beside the man, carefully cleaned his wounds, and bandaged them. Then he lifted the man onto his own donkey and took him to an inn.","He even paid the innkeeper to take care of the man until he was better.","\"Which one was a true neighbor?\" Jesus asked. \"The one who showed kindness,\" came the answer. \"Go and do the same,\" Jesus said with a smile."],
    touchElements:[{emoji:"❤️",x:50,y:15,tap:"A heart full of compassion!"},{emoji:"🩹",x:25,y:22,tap:"Gently bandaging the wounds"},{emoji:"🫏",x:72,y:20,tap:"The donkey clip-clops along!"}]},
  {id:"daniel-lions",title:"Daniel & the Lions",sub:"Faith conquers fear",ref:"Daniel 6",cat:"Courage",age:"6-8",dur:9,color:"#eab308",emoji:"🦁",mascotReact:"Lumi roars softly! Rawr! 🦁",
    prayer:"Dear God, give me courage like Daniel. Help me to always be faithful to You. Amen.",
    takeaway:"When we stay faithful to God, He protects us even in scary situations.",
    verse:'"My God sent his angel and shut the lions\' mouths." — Daniel 6:22',
    text:["Daniel was a man who loved God with all his heart. Three times every day, he would open his window and pray, thanking God for His goodness.","Daniel was so wise and honest that the king made him one of the most important people in the whole kingdom. This made some other men very jealous.","These jealous men convinced the king to make a new law: \"For thirty days, everyone must pray only to the king. Anyone who prays to anyone else will be thrown into the den of lions!\"","When Daniel heard about the new law, do you know what he did? He went straight to his window, knelt down, and prayed to God — just like he always did.","The jealous men caught Daniel praying and told the king. The king was very sad, but the law was the law. Daniel was thrown into the pit of hungry lions.","But God sent an angel to close the lions' mouths! All night long, Daniel sat safely among the lions. They were as gentle as kittens.","In the morning, the king rushed to the den. \"Daniel! Did your God save you?\" \"Yes!\" Daniel called back. \"God sent His angel to protect me!\""],
    touchElements:[{emoji:"😺",x:35,y:20,tap:"The lion purrs like a kitten!"},{emoji:"👼",x:65,y:12,tap:"An angel watches over Daniel!"},{emoji:"🙏",x:50,y:25,tap:"Daniel prays faithfully"}]},
  {id:"creation",title:"Creation",sub:"God made everything beautiful",ref:"Genesis 1-2",cat:"Hope",age:"3-5",dur:8,color:"#22c55e",emoji:"🌍",mascotReact:"Lumi gazes at the stars! ✨",
    prayer:"Dear God, thank You for making this beautiful world. Help me take care of it. Amen.",
    takeaway:"God created the whole world with love, and He made you special too.",
    verse:'"God saw all that he had made, and it was very good." — Genesis 1:31',
    text:["In the very beginning, before there was anything at all, God spoke — and amazing things began to happen.","On the first day, God said, \"Let there be light!\" And warm, golden light appeared, pushing away the darkness.","On the second day, God made the beautiful blue sky, stretching it high above like a big, soft blanket. On the third day, dry land appeared with green grass, colorful flowers, and tall trees.","On the fourth day, God placed the bright sun in the sky for daytime, the gentle moon for nighttime, and scattered millions of twinkling stars across the heavens.","On the fifth day, God filled the oceans with fish of every color and the sky with birds that could sing the most beautiful songs.","On the sixth day, God made all the animals — bouncy rabbits, cuddly bears, spotted giraffes! And then, the most special creation of all — God made people, in His own image.","On the seventh day, God looked at everything He had made and smiled. It was all very good. Every sunrise, every flower, every star — they're all God's gifts to you."],
    touchElements:[{emoji:"☀️",x:70,y:10,tap:"The sun shines warm and bright!"},{emoji:"🌸",x:25,y:22,tap:"Beautiful flowers bloom!"},{emoji:"🐦",x:55,y:15,tap:"A little bird sings a song!"}]},
  {id:"jesus-storm",title:"Jesus Calms the Storm",sub:"Peace in the chaos",ref:"Mark 4:35-41",cat:"Peace",age:"3-5",dur:7,color:"#6366f1",emoji:"⛵",mascotReact:"Lumi feels so peaceful! 😌",
    prayer:"Dear God, when life feels stormy, help me remember that You are always with me. Amen.",
    takeaway:"Jesus has power over everything, and we can find peace in Him.",
    verse:'"Peace, be still." — Mark 4:39',
    text:["One evening, after a long day of teaching, Jesus said to His friends, \"Let's go to the other side of the lake.\" So they all climbed into a little boat and set off.","Jesus was so tired that He fell asleep on a cushion at the back of the boat. The gentle rocking of the waves was like a lullaby.","But suddenly, a great storm came! The wind howled and the waves crashed against the boat. Water splashed over the sides!","The friends were very scared. \"We're going to sink!\" they cried. They shook Jesus awake. \"Teacher! Don't you care that we're about to drown?!\"","Jesus stood up calmly. He looked at the wild wind and the crashing waves. Then He spoke in a strong, gentle voice: \"Peace, be still.\"","And just like that — everything stopped. The wind became quiet. The waves became smooth as glass. The storm was completely gone.","Whenever you feel scared or worried, remember — Jesus is with you, and He can calm any storm."],
    touchElements:[{emoji:"🌊",x:30,y:20,tap:"The waves become calm and still!"},{emoji:"💨",x:65,y:12,tap:"Whoosh! The wind dies down"},{emoji:"✨",x:50,y:18,tap:"Peace fills the air"}]},
];

const CATS=[
  {n:"Trust",i:"🤲",bg:"linear-gradient(135deg,#3b82f6,#06b6d4)"},
  {n:"Courage",i:"🛡️",bg:"linear-gradient(135deg,#f97316,#ef4444)"},
  {n:"Peace",i:"🍃",bg:"linear-gradient(135deg,#22c55e,#10b981)"},
  {n:"Love",i:"❤️",bg:"linear-gradient(135deg,#ec4899,#f43f5e)"},
  {n:"Hope",i:"☀️",bg:"linear-gradient(135deg,#eab308,#f97316)"},
  {n:"Prayer",i:"🙏",bg:"linear-gradient(135deg,#8b5cf6,#6366f1)"},
  {n:"Kindness",i:"😊",bg:"linear-gradient(135deg,#14b8a6,#22c55e)"},
];

const BADGES=[
  {id:"first-story",name:"First Light",icon:"⭐",desc:"Read your first story"},
  {id:"bookworm",name:"Bookworm",icon:"📚",desc:"Read 5 stories"},
  {id:"explorer",name:"Explorer",icon:"🗺️",desc:"Read 10 stories"},
  {id:"3-day",name:"Getting Started",icon:"🔥",desc:"3-day streak"},
  {id:"week",name:"Week Warrior",icon:"⚡",desc:"7-day streak"},
  {id:"faithful",name:"Faithful",icon:"✨",desc:"14-day streak"},
  {id:"scholar",name:"Scholar",icon:"🎓",desc:"Read 25 stories"},
  {id:"champion",name:"Champion",icon:"🏆",desc:"30-day streak"},
  {id:"master",name:"Master",icon:"👑",desc:"Read all 50"},
];

const QS={
  Trust:["What does it mean to trust God?","Can you think of a time you had to trust someone?","How did the person in the story show trust?"],
  Courage:["What made the person brave?","When were you really brave?","How can God help when we feel scared?"],
  Peace:["What makes you feel peaceful?","How did God bring peace?","What can you do when you feel worried?"],
  Love:["How did people show love?","How do you show love to family?","How does God show us His love?"],
  Hope:["What does hope mean to you?","How did hope help in this story?","What makes you hopeful about tomorrow?"],
  Prayer:["What's your favorite thing to pray about?","How did prayer help?","When do you like to talk to God?"],
  Kindness:["How was kindness shown?","What's the nicest thing someone did for you?","How can you be kind tomorrow?"],
};

const AFFIRM=["I am loved by God","I am brave and strong","God is always with me","I am kind and good","Tomorrow is a new adventure"];

const COLLECTIBLES=[
  {id:"rainbow",name:"Rainbow",emoji:"🌈",story:"noahs-ark"},
  {id:"sling",name:"Sling",emoji:"🪨",story:"david-goliath"},
  {id:"heart",name:"Kind Heart",emoji:"💝",story:"good-samaritan"},
  {id:"lion",name:"Gentle Lion",emoji:"🦁",story:"daniel-lions"},
  {id:"flower",name:"First Flower",emoji:"🌸",story:"creation"},
  {id:"boat",name:"Little Boat",emoji:"⛵",story:"jesus-storm"},
];

/* ━━━━━━━━━━━━━━━ COMPONENTS ━━━━━━━━━━━━━━━ */

// Starry sky
function Sky(){
  const [s]=useState(()=>Array.from({length:50},(_,i)=>({i,x:Math.random()*100,y:Math.random()*100,sz:Math.random()*2.5+.5,d:Math.random()*4,dur:Math.random()*2+1.5})));
  return <div className="absolute inset-0 overflow-hidden" style={{background:"linear-gradient(180deg,#070714 0%,#0d0b1e 40%,#151030 100%)"}}>
    <div className="absolute top-16 left-1/2 -translate-x-1/2 w-96 h-48 rounded-full opacity-15" style={{background:"radial-gradient(ellipse,#6366f1,transparent 70%)"}}/>
    {s.map(v=><div key={v.i} className="absolute rounded-full bg-white" style={{left:`${v.x}%`,top:`${v.y}%`,width:v.sz,height:v.sz,animation:`twinkle ${v.dur}s ease-in-out ${v.d}s infinite alternate`}}/>)}
  </div>;
}

// Mascot - Lumi the firefly
function Lumi({message,size=40}){
  const [vis,setVis]=useState(false);
  useEffect(()=>{if(message)setVis(true);const t=setTimeout(()=>setVis(false),3000);return()=>clearTimeout(t);},[message]);
  return <div className="relative inline-flex items-center" style={{animation:"float 3s ease-in-out infinite"}}>
    <div style={{fontSize:size,animation:"glow 2s ease-in-out infinite",filter:"drop-shadow(0 0 8px rgba(250,204,21,.4))"}}>✨</div>
    {vis&&message&&<div className="absolute left-full ml-2 whitespace-nowrap px-3 py-1.5 rounded-full text-xs font-bold text-white" style={{background:"rgba(99,102,241,.85)",animation:"popIn .3s ease-out both",backdropFilter:"blur(8px)"}}>{message}</div>}
  </div>;
}

// Confetti burst
function Confetti(){
  const items=Array.from({length:20},(_,i)=>({i,x:Math.random()*100,rot:Math.random()*720-360,color:["#facc15","#818cf8","#f472b6","#22d3ee","#fb923c"][i%5],delay:Math.random()*.4,size:Math.random()*6+4}));
  return <div className="fixed inset-0 z-50 pointer-events-none overflow-hidden">
    {items.map(c=><div key={c.i} className="absolute" style={{left:`${c.x}%`,top:-10,width:c.size,height:c.size*1.5,background:c.color,borderRadius:2,["--rot"]:c.rot+"deg",animation:`confettiFall 1.5s ease-in ${c.delay}s both`}}/>)}
  </div>;
}

// Celebration overlay
function Celebration({collectible,onDone}){
  useEffect(()=>{const t=setTimeout(onDone,3200);return()=>clearTimeout(t);},[]);
  return <div className="fixed inset-0 z-50 flex items-center justify-center" style={{background:"rgba(0,0,0,.6)",backdropFilter:"blur(6px)"}}>
    <Confetti/>
    <div className="text-center" style={{animation:"popIn .5s cubic-bezier(.34,1.56,.64,1) both"}}>
      <div className="text-7xl mb-4" style={{animation:"bounce 1s ease-in-out infinite"}}>✅</div>
      <p className="text-white text-2xl font-bold mb-2">Story Complete!</p>
      <p className="text-yellow-400 font-bold mb-1">+1 Sleep Star ⭐</p>
      {collectible&&<div className="mt-4 px-5 py-3 rounded-2xl inline-flex items-center gap-2" style={{background:"rgba(99,102,241,.2)",animation:"popIn .4s ease-out .5s both"}}>
        <span className="text-2xl">{collectible.emoji}</span>
        <div className="text-left"><p className="text-white text-xs font-bold">New Collectible!</p><p className="text-indigo-300 text-xs">{collectible.name}</p></div>
      </div>}
    </div>
  </div>;
}

// Touch interaction bubble
function TouchBubble({text,x,y,onDone}){
  useEffect(()=>{const t=setTimeout(onDone,2000);return()=>clearTimeout(t);},[]);
  return <div className="absolute z-30 pointer-events-none" style={{left:`${x}%`,top:`${y}%`,transform:"translate(-50%,-100%)",animation:"popIn .3s ease-out both"}}>
    <div className="px-3 py-1.5 rounded-full text-xs font-bold text-white whitespace-nowrap" style={{background:"rgba(99,102,241,.9)",boxShadow:"0 4px 20px rgba(99,102,241,.4)"}}>{text}</div>
  </div>;
}

// Audio player with read-along
function Player({story,bed,onFinish}){
  const [playing,setPlaying]=useState(false);
  const [prog,setProg]=useState(0);
  const [time,setTime]=useState(0);
  const [paraIdx,setParaIdx]=useState(0);
  const iv=useRef(null);
  const total=story.dur*60;
  const parasPerSec=story.text.length/total;

  useEffect(()=>{
    if(playing){
      iv.current=setInterval(()=>{
        setTime(t=>{
          const n=t+1;
          setProg(n/total);
          setParaIdx(Math.min(Math.floor(n*parasPerSec),story.text.length-1));
          if(n>=total){clearInterval(iv.current);setPlaying(false);onFinish?.();return total;}
          return n;
        });
      },1000);
    }else clearInterval(iv.current);
    return()=>clearInterval(iv.current);
  },[playing]);

  const fmt=s=>`${Math.floor(s/60)}:${String(s%60).padStart(2,'0')}`;
  const bars=Array.from({length:36},(_,i)=>({i,h:Math.random()*20+4}));

  return <div className={`rounded-2xl p-4 ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
    <div className="flex items-center gap-3 mb-3">
      <button onClick={()=>setPlaying(!playing)} className="w-14 h-14 rounded-full flex items-center justify-center text-white shrink-0 active:scale-90 transition-transform" style={{background:`linear-gradient(135deg,${story.color},#7c3aed)`,boxShadow:`0 4px 20px ${story.color}44`}}>
        <span style={{fontSize:20,marginLeft:playing?0:3}}>{playing?"⏸":"▶"}</span>
      </button>
      <div className="flex-1 min-w-0">
        <p className={`text-xs font-bold mb-1 ${bed?"text-white/60":"text-gray-500"}`}>{playing?"Now playing...":"Tap to listen"}</p>
        <div className="flex items-end gap-[2px] h-7 mb-1.5">
          {bars.map(b=><div key={b.i} className="flex-1 rounded-full transition-all" style={{
            background:b.i/36<=prog?(bed?"#818cf8":"#6366f1"):(bed?"rgba(255,255,255,.06)":"#e5e7eb"),
            height:playing?undefined:Math.max(3,b.h*(prog||.05)),
            ["--h"]:b.h+"px",
            animation:playing?`wave ${.3+Math.random()*.4}s ease-in-out ${Math.random()*.3}s infinite alternate`:undefined,
          }}/>)}
        </div>
        <div className="flex justify-between">
          <span className={`text-xs font-medium ${bed?"text-gray-600":"text-gray-400"}`}>{fmt(time)}</span>
          <span className={`text-xs font-medium ${bed?"text-gray-600":"text-gray-400"}`}>{fmt(total)}</span>
        </div>
      </div>
    </div>
    {/* Scrubber */}
    <div className={`h-1.5 rounded-full cursor-pointer ${bed?"bg-white/[.06]":"bg-gray-200"}`}
      onClick={e=>{const r=e.currentTarget.getBoundingClientRect();const p=Math.max(0,Math.min(1,(e.clientX-r.left)/r.width));setProg(p);setTime(Math.floor(p*total));setParaIdx(Math.min(Math.floor(p*total*parasPerSec),story.text.length-1));}}>
      <div className="h-full rounded-full relative" style={{width:`${prog*100}%`,background:`linear-gradient(90deg,${story.color},#7c3aed)`,transition:"width .3s"}}>
        <div className="absolute right-0 top-1/2 -translate-y-1/2 w-3 h-3 rounded-full bg-white shadow-md" style={{display:prog>0?"block":"none"}}/>
      </div>
    </div>
    {playing&&<p className={`text-xs mt-2 ${bed?"text-indigo-400":"text-indigo-600"}`}>📖 Following along: paragraph {paraIdx+1} of {story.text.length}</p>}
  </div>;
}

/* ━━━━━━━━━━━━━━━ SCREENS ━━━━━━━━━━━━━━━ */

// Onboarding
function Onboarding({onDone}){
  const [pg,setPg]=useState(0);
  const [name,setName]=useState("");
  const [age,setAge]=useState(null);
  const [v,setV]=useState(false);
  useEffect(()=>{setTimeout(()=>setV(true),300)},[]);

  const P=({children})=><div className="flex-1 flex flex-col items-center justify-center px-8 fadeUp">{children}</div>;

  return <div className="h-full relative overflow-hidden flex flex-col" style={{background:"linear-gradient(180deg,#070714,#0d0b1e 50%,#151030)"}}>
    <Sky/>
    <div className="relative z-10 flex-1 flex flex-col">
      {pg===0&&<P>
        <div className="relative mb-6"><Lumi size={56} message="Hi there!"/></div>
        <div className="mb-6" style={{transition:"all .8s cubic-bezier(.34,1.56,.64,1)",transform:`scale(${v?1:.2})`,opacity:v?1:0}}>
          <span style={{fontSize:80}}>🌙</span>
        </div>
        <h1 className="text-4xl font-bold text-white mb-1">Little Lights</h1>
        <p className="text-2xl font-bold mb-2" style={{color:"#818cf8"}}>Bible Bedtime</p>
        <p className="text-white/40 text-sm mb-10 text-center leading-relaxed">Beautiful Bible stories to help<br/>your little one drift off to sleep</p>
        <button onClick={()=>setPg(1)} className="w-full py-4 rounded-2xl font-bold text-white text-lg active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)",boxShadow:"0 4px 24px rgba(99,102,241,.4)"}}>Get Started</button>
      </P>}

      {pg===1&&<P>
        <Lumi size={36} message="What's your name?"/>
        <h2 className="text-2xl font-bold text-white mb-8 mt-4">Who's listening tonight?</h2>
        <div className="w-full mb-5">
          <label className="text-white/30 text-xs font-bold mb-2 block tracking-widest">CHILD'S NAME</label>
          <input value={name} onChange={e=>setName(e.target.value)} placeholder="Enter name" className="w-full p-4 rounded-2xl bg-white/[.06] border border-white/10 text-white text-lg outline-none focus:border-indigo-400 transition-colors"/>
        </div>
        <div className="w-full mb-8">
          <label className="text-white/30 text-xs font-bold mb-3 block tracking-widest">AGE GROUP</label>
          <div className="flex gap-3">{[{l:"3-5",e:"👶",sub:"Toddler"},{l:"6-8",e:"🧒",sub:"Child"},{l:"9-12",e:"📖",sub:"Preteen"}].map(a=>
            <button key={a.l} onClick={()=>setAge(a.l)} className={`flex-1 py-4 rounded-2xl font-bold text-sm border-2 transition-all active:scale-95`} style={{background:age===a.l?"rgba(99,102,241,.25)":"rgba(255,255,255,.03)",borderColor:age===a.l?"#6366f1":"rgba(255,255,255,.08)",color:age===a.l?"white":"rgba(255,255,255,.5)"}}>
              <div className="text-2xl mb-1">{a.e}</div><div>{a.l}</div><div className="text-xs opacity-50 mt-0.5">{a.sub}</div>
            </button>
          )}</div>
        </div>
        <button onClick={()=>setPg(2)} className="w-full py-4 rounded-2xl font-bold text-white text-lg active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)",boxShadow:"0 4px 24px rgba(99,102,241,.4)"}}>Continue</button>
      </P>}

      {pg===2&&<P>
        <Lumi size={44} message="Let's go!"/>
        <div className="text-5xl mb-4 mt-4">✨</div>
        <h2 className="text-3xl font-bold text-white mb-6">You're all set!</h2>
        <div className="w-full space-y-4 mb-10">{[["📖","50 Bible stories with audio narration"],["🌙","Bedtime routine with sleep timer"],["🌬️","Guided breathing for peaceful sleep"],["✨","Meet Lumi, your bedtime friend"],["⭐","Collect items & earn badges"],["❤️","100% free — always"]].map(([ic,tx])=>
          <div key={tx} className="flex items-center gap-4 fadeUp"><span className="text-2xl">{ic}</span><span className="text-white/70 text-sm">{tx}</span></div>
        )}</div>
        <button onClick={()=>onDone(name)} className="w-full py-4 rounded-2xl font-bold text-white text-lg active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)",boxShadow:"0 4px 24px rgba(99,102,241,.4)"}}>Start Exploring →</button>
      </P>}
    </div>
    <div className="relative z-10 flex justify-center gap-2 pb-10">{[0,1,2].map(i=><div key={i} className={`h-2 rounded-full transition-all duration-300 ${i===pg?"w-6 bg-white":"w-2 bg-white/15"}`}/>)}</div>
  </div>;
}

// Breathing Exercise
function Breathing({onBack}){
  const [phase,setPhase]=useState("ready");
  const [cyc,setCyc]=useState(0);
  const [label,setLabel]=useState("Get Cozy");
  const [emoji,setEmoji]=useState("🌙");
  const [scale,setScale]=useState(.5);
  const t=useRef([]);
  const clr=()=>t.current.forEach(clearTimeout);

  const run=(c)=>{
    if(c>=4){setPhase("done");setLabel("All Done!");setEmoji("⭐");setScale(.7);return;}
    setPhase("inhale");setLabel("Smell the flowers");setEmoji("🌸");setScale(1);
    t.current.push(setTimeout(()=>{setPhase("hold");setLabel("Hold it gently");setEmoji("✨");},4000));
    t.current.push(setTimeout(()=>{setPhase("exhale");setLabel("Blow out the candles");setEmoji("🕯️");setScale(.5);},8000));
    t.current.push(setTimeout(()=>{setCyc(c+1);setPhase("rest");setLabel("Rest");setEmoji("🌙");},12000));
    t.current.push(setTimeout(()=>run(c+1),14000));
  };
  useEffect(()=>()=>clr(),[]);

  return <div className="h-full flex flex-col" style={{background:"linear-gradient(180deg,#070714,#151030)"}}>
    <div className="flex items-center px-4 py-3"><button onClick={()=>{clr();onBack();}} className="text-white/40 text-sm active:text-white">← Back</button><p className="flex-1 text-center text-white font-bold">Breathing Exercise</p><div className="w-12"/></div>
    <p className="text-center text-white/30 text-sm">Let's calm our body and mind</p>
    <div className="flex-1 flex flex-col items-center justify-center">
      <Lumi size={28} message={phase==="inhale"?"Breathe in...":phase==="exhale"?"Breathe out...":null}/>
      <div className="rounded-full flex flex-col items-center justify-center mt-6" style={{width:200,height:200,background:"radial-gradient(circle,rgba(129,140,248,.4),rgba(129,140,248,.08))",transform:`scale(${scale})`,transition:"transform 4s ease-in-out",boxShadow:`0 0 ${scale*80}px rgba(129,140,248,${scale*.35})`}}>
        <span style={{fontSize:44}}>{emoji}</span>
        <span className="text-white font-bold text-sm mt-2">{label}</span>
      </div>
      <div className="flex gap-3 mt-8 mb-2">{[0,1,2,3].map(i=><div key={i} className={`w-3 h-3 rounded-full transition-colors duration-500 ${i<cyc?"bg-indigo-400":"bg-indigo-400/15"}`}/>)}</div>
      <p className="text-white/25 text-xs">Breath {Math.min(cyc+1,4)} of 4</p>
    </div>
    <div className="p-6">
      {phase==="ready"&&<button onClick={()=>run(0)} className="w-full py-4 rounded-2xl font-bold text-white active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)",boxShadow:"0 4px 24px rgba(99,102,241,.4)"}}>🌬️ Begin</button>}
      {phase==="done"&&<div className="text-center"><p className="text-white font-bold text-lg mb-1">Sweet dreams ahead</p><p className="text-white/30 text-sm mb-4">Your body is calm and ready for sleep</p><button onClick={onBack} className="w-full py-4 rounded-2xl font-bold text-white active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)"}}>📖 Continue</button></div>}
      {!["ready","done"].includes(phase)&&<button onClick={()=>{clr();setPhase("ready");setLabel("Get Cozy");setEmoji("🌙");setCyc(0);setScale(.5);}} className="w-full text-center text-white/20 text-sm py-2">Stop</button>}
    </div>
  </div>;
}

// Affirmations
function Affirm({onClose}){
  const items=AFFIRM.slice(0,3);
  const [idx,setIdx]=useState(0);
  const [op,setOp]=useState(1);
  const [done,setDone]=useState(false);
  const go=()=>{setOp(0);setTimeout(()=>{if(idx<items.length-1){setIdx(idx+1);setOp(1);}else{setDone(true);setOp(1);}},400);};
  return <div className="h-full flex flex-col items-center justify-center px-8" style={{background:"#070714"}}>
    <Lumi size={32} message={!done?items[idx]:null}/>
    <div className="mb-8 mt-4" style={{filter:"drop-shadow(0 0 40px rgba(250,204,21,.2))"}}>
      <span style={{fontSize:56,animation:"glow 2s ease-in-out infinite"}}>⭐</span>
    </div>
    {!done?<>
      <p className="text-3xl font-bold text-white text-center mb-10" style={{transition:"opacity .4s",opacity:op}}>{items[idx]}</p>
      <div className="flex gap-3 mb-10">{items.map((_,i)=><div key={i} className={`w-2.5 h-2.5 rounded-full transition-colors ${i<=idx?"bg-yellow-400":"bg-white/10"}`}/>)}</div>
      <button onClick={go} className="text-white/30 font-bold text-lg active:text-white/60">Next →</button>
    </>:<>
      <p className="text-2xl text-white/25 mb-6">Sweet Dreams</p>
      <button onClick={onClose} className="px-10 py-4 rounded-2xl font-bold text-white active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)"}}>🌙 Goodnight</button>
    </>}
  </div>;
}

// Story Detail - the big one
function StoryDetail({story,bed,onBack,favs,toggleFav,markRead,reads,collected}){
  const [showAffirm,setShowAffirm]=useState(false);
  const [showCeleb,setShowCeleb]=useState(false);
  const [touchMsg,setTouchMsg]=useState(null);
  const [lumiMsg,setLumiMsg]=useState(null);
  const [activeP,setActiveP]=useState(-1);
  const isRead=reads.has(story.id);
  const isFav=favs.has(story.id);
  const qs=QS[story.cat]||QS.Trust;
  const collectible=COLLECTIBLES.find(c=>c.story===story.id);
  const hasCollected=collected.has(collectible?.id);

  const handleTouch=(el)=>{setTouchMsg({text:el.tap,x:el.x,y:el.y});};

  if(showAffirm) return <Affirm onClose={()=>setShowAffirm(false)}/>;

  return <div className="h-full flex flex-col relative">
    {bed&&<Sky/>}
    {showCeleb&&<Celebration collectible={!hasCollected?collectible:null} onDone={()=>setShowCeleb(false)}/>}
    <div className={`relative z-10 flex-1 overflow-y-auto ${bed?"":"bg-gray-50"}`}>
      {/* Hero with touch elements */}
      <div className="relative h-64" style={{background:`linear-gradient(135deg,${story.color}dd,#7c3aed)`}}>
        <div className="absolute inset-0 flex items-center justify-center text-9xl opacity-15">{story.emoji}</div>
        <button onClick={onBack} className="absolute top-4 left-4 z-20 w-9 h-9 rounded-full bg-black/30 glass flex items-center justify-center text-white text-sm active:bg-black/50">←</button>
        {/* Interactive touch elements */}
        {story.touchElements?.map((el,i)=><button key={i} onClick={()=>handleTouch(el)} className="absolute text-2xl active:scale-125 transition-transform" style={{left:`${el.x}%`,top:`${el.y}%`,animation:`float ${2+i*.5}s ease-in-out ${i*.3}s infinite`,filter:"drop-shadow(0 2px 8px rgba(0,0,0,.3))"}}>
          {el.emoji}
        </button>)}
        {touchMsg&&<TouchBubble text={touchMsg.text} x={touchMsg.x} y={touchMsg.y} onDone={()=>setTouchMsg(null)}/>}
        <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-transparent to-transparent"/>
        <div className="absolute bottom-0 left-0 p-5">
          <div className="flex items-center gap-2 mb-1">
            <span className="text-xs px-2.5 py-1 bg-white/20 rounded-full text-white/90 glass font-medium">Ages {story.age}</span>
            {isRead&&<span className="text-xs px-2 py-1 bg-green-500/20 rounded-full text-green-300 font-medium">✓ Read</span>}
          </div>
          <h1 className="text-3xl font-bold text-white mt-1">{story.title}</h1>
          <p className="text-white/50 text-sm">{story.sub}</p>
        </div>
      </div>

      <div className="p-5 space-y-5">
        {/* Lumi mascot reaction */}
        <div className="flex items-center gap-2 fadeUp">
          <Lumi size={28} message={lumiMsg}/>
          <button onClick={()=>setLumiMsg(story.mascotReact)} className={`text-xs px-3 py-1.5 rounded-full font-bold active:scale-95 ${bed?"bg-white/[.04] text-white/40":"bg-gray-100 text-gray-500"}`}>
            Tap to say hi to Lumi ✨
          </button>
        </div>

        {/* Info */}
        <div className={`flex text-xs font-medium fadeUp d1 ${bed?"text-gray-500":"text-gray-400"}`}>
          <span>📖 {story.ref}</span><span className="mx-3">·</span><span>⏱ {story.dur} min</span><span className="mx-3">·</span><span>{CATS.find(c=>c.n===story.cat)?.i} {story.cat}</span>
        </div>

        {/* Player + Fav */}
        <div className="flex gap-3 fadeUp d2">
          <div className="flex-1"><Player story={story} bed={bed} onFinish={()=>{if(!isRead){markRead(story.id);setShowCeleb(true);}}}/></div>
          <button onClick={()=>toggleFav(story.id)} className={`w-14 shrink-0 rounded-2xl flex items-center justify-center text-2xl active:scale-90 transition-transform ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`} style={{boxShadow:isFav?"0 0 20px rgba(244,63,94,.2)":undefined}}>
            {isFav?"❤️":"🤍"}
          </button>
        </div>

        {/* Quick Controls */}
        <div className="flex gap-2 fadeUp d3">{[{i:"⏱",l:"Timer"},{i:"🌧️",l:"Sounds"},{i:bed?"🌙":"☀️",l:bed?"Bedtime":"Daytime"}].map(c=>
          <div key={c.l} className={`flex-1 flex flex-col items-center py-3 rounded-xl active:scale-95 transition-transform cursor-pointer ${bed?"bg-white/[.04]":"bg-gray-100"}`}>
            <span className="text-lg">{c.i}</span><span className={`text-xs mt-0.5 ${bed?"text-gray-500":"text-gray-500"}`}>{c.l}</span>
          </div>
        )}</div>

        {/* Memory Verse */}
        {story.verse&&<div className="fadeUp d4">
          <h3 className={`font-bold mb-2 flex items-center gap-2 ${bed?"text-white":"text-gray-900"}`}>📜 Memory Verse</h3>
          <div className={`p-4 rounded-2xl ${bed?"bg-indigo-500/[.08] text-indigo-300":"bg-indigo-50 text-indigo-700"}`} style={{fontFamily:"Georgia,serif",fontStyle:"italic",lineHeight:"1.8"}}>{story.verse}</div>
        </div>}

        {/* Story with read-along highlighting */}
        <div className="fadeUp d5">
          <h3 className={`text-xl font-bold mb-4 ${bed?"text-white":"text-gray-900"}`}>Story</h3>
          {story.text.map((para,i)=><p key={i} className={`mb-4 leading-relaxed cursor-pointer transition-all rounded-lg px-1 -mx-1 ${bed?"text-gray-300":"text-gray-700"} ${activeP===i?(bed?"bg-indigo-500/10":"bg-indigo-50"):""}`} style={{fontSize:17,lineHeight:bed?"2em":"1.8em"}} onClick={()=>setActiveP(activeP===i?-1:i)}>
            {para}
          </p>)}
        </div>

        {/* Takeaway */}
        <div className={`p-4 rounded-2xl ${bed?"bg-white/[.03]":"bg-amber-50"}`}>
          <h3 className={`font-bold mb-2 flex items-center gap-2 ${bed?"text-white":"text-gray-900"}`}>💡 Takeaway</h3>
          <p className={`text-sm leading-relaxed ${bed?"text-gray-400":"text-gray-600"}`}>{story.takeaway}</p>
        </div>

        {/* Discussion */}
        <div className={`p-4 rounded-2xl ${bed?"bg-white/[.03]":"bg-white shadow-sm"}`}>
          <h3 className={`font-bold mb-1 flex items-center gap-2 ${bed?"text-white":"text-gray-900"}`}>💬 Talk Together</h3>
          <p className={`text-xs mb-4 ${bed?"text-gray-600":"text-gray-400"}`}>Questions to explore with your child</p>
          {qs.map((q,i)=><div key={i} className="flex gap-3 mb-3 last:mb-0">
            <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold shrink-0 ${bed?"bg-indigo-500/10 text-indigo-400":"bg-indigo-100 text-indigo-600"}`}>{i+1}</div>
            <p className={`text-sm leading-relaxed ${bed?"text-gray-300":"text-gray-700"}`}>{q}</p>
          </div>)}
        </div>

        {/* Prayer */}
        <div>
          <h3 className={`font-bold mb-2 flex items-center gap-2 ${bed?"text-white":"text-gray-900"}`}>🙏 Bedtime Prayer</h3>
          <div className={`p-4 rounded-2xl leading-relaxed ${bed?"bg-white/[.03] text-gray-300":"bg-gray-100 text-gray-600"}`}>{story.prayer}</div>
        </div>

        {/* Affirmations button */}
        {bed&&<button onClick={()=>setShowAffirm(true)} className="w-full flex items-center gap-3 p-4 rounded-2xl active:scale-[.98] transition-transform" style={{background:"linear-gradient(135deg,rgba(67,56,202,.1),rgba(124,58,237,.06))"}}>
          <span className="text-xl" style={{animation:"glow 2s infinite"}}>⭐</span>
          <div className="flex-1 text-left"><p className="text-white text-sm font-bold">Goodnight Affirmations</p><p className="text-white/25 text-xs">Positive words before sleep</p></div>
          <span className="text-white/15">›</span>
        </button>}

        {/* Collectible preview */}
        {collectible&&<div className={`flex items-center gap-3 p-4 rounded-2xl ${bed?"bg-white/[.03]":"bg-gray-50"}`}>
          <span className="text-3xl">{collectible.emoji}</span>
          <div className="flex-1">
            <p className={`text-sm font-bold ${bed?"text-white":"text-gray-900"}`}>{collectible.name}</p>
            <p className={`text-xs ${bed?"text-gray-500":"text-gray-400"}`}>{hasCollected||isRead?"Collected!":"Complete this story to collect"}</p>
          </div>
          {(hasCollected||isRead)&&<span className="text-green-400">✓</span>}
        </div>}

        {/* Mark as Read */}
        <button onClick={()=>{if(!isRead){markRead(story.id);setShowCeleb(true);}}} className={`w-full py-4 rounded-2xl font-bold transition-all active:scale-95 ${isRead?(bed?"bg-green-500/10 text-green-400":"bg-green-100 text-green-700"):(bed?"bg-white/[.04] text-indigo-400":"bg-gray-100 text-indigo-600")}`}>
          {isRead?"✅ Completed":"☐ Mark as Read"}
        </button>
        <div className="h-6"/>
      </div>
    </div>
  </div>;
}

// Bedtime Routine
function Routine({bed,onBack,onStory}){
  const [breath,setBreath]=useState(false);
  const [timer,setTimer]=useState(30);
  const [sound,setSound]=useState("Rain");
  if(breath) return <Breathing onBack={()=>setBreath(false)}/>;

  return <div className="h-full flex flex-col relative">
    {bed&&<Sky/>}
    <div className={`relative z-10 flex-1 overflow-y-auto ${bed?"":"bg-gray-50"}`}>
      <div className="flex items-center px-4 py-3"><button onClick={onBack} className={`text-sm ${bed?"text-white/40":"text-gray-500"} active:opacity-70`}>← Back</button><p className={`flex-1 text-center font-bold ${bed?"text-white":"text-gray-900"}`}>Bedtime Routine</p><div className="w-12"/></div>
      <div className="p-5 space-y-4">
        <div className="text-center mb-2"><Lumi size={32} message="Time for bed!"/></div>

        <button onClick={()=>onStory(STORIES[0])} className={`w-full p-4 rounded-2xl flex items-center gap-3 text-left active:scale-[.98] transition-transform ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
          <div className="w-12 h-12 rounded-xl flex items-center justify-center text-xl" style={{background:`linear-gradient(135deg,${STORIES[0].color},#7c3aed)`}}>{STORIES[0].emoji}</div>
          <div className="flex-1"><p className={`font-bold text-sm ${bed?"text-white":"text-gray-900"}`}>Tonight's Story</p><p className={`text-xs ${bed?"text-gray-500":"text-gray-400"}`}>{STORIES[0].title}</p></div>
          <span className="text-green-400">✓</span>
        </button>

        <div className={`p-4 rounded-2xl ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
          <p className={`font-bold text-sm mb-3 ${bed?"text-white":"text-gray-900"}`}>⏱ Sleep Timer</p>
          <div className="flex gap-2">{[15,30,45,60].map(m=><button key={m} onClick={()=>setTimer(m)} className={`flex-1 py-2.5 rounded-xl text-sm font-bold transition-all active:scale-95`} style={{background:timer===m?`linear-gradient(135deg,#4f46e5,#7c3aed)`:(bed?"rgba(255,255,255,.03)":"#f3f4f6"),color:timer===m?"white":"#9ca3af"}}>{m}m</button>)}</div>
        </div>

        <div className={`p-4 rounded-2xl ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
          <p className={`font-bold text-sm mb-3 ${bed?"text-white":"text-gray-900"}`}>🎵 Ambient Sound</p>
          <div className="flex gap-2 flex-wrap">{["None","Rain","Ocean","Crickets","Fireplace","Lullaby"].map(s=><button key={s} onClick={()=>setSound(s)} className={`px-3 py-2 rounded-xl text-xs font-bold transition-all active:scale-95`} style={{background:sound===s?"linear-gradient(135deg,#4f46e5,#7c3aed)":(bed?"rgba(255,255,255,.03)":"#f3f4f6"),color:sound===s?"white":"#9ca3af"}}>{s}</button>)}</div>
        </div>

        <button onClick={()=>setBreath(true)} className={`w-full flex items-center gap-3 p-4 rounded-2xl text-left active:scale-[.98] transition-transform ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
          <div className="w-11 h-11 rounded-full flex items-center justify-center" style={{background:"linear-gradient(135deg,#06b6d4,#14b8a6)"}}><span className="text-lg">🌬️</span></div>
          <div className="flex-1"><p className={`font-bold text-sm ${bed?"text-white":"text-gray-900"}`}>Breathing Exercise</p><p className={`text-xs ${bed?"text-gray-500":"text-gray-400"}`}>Calm body and mind</p></div>
          <span className={`text-xs ${bed?"text-gray-700":"text-gray-300"}`}>Optional ›</span>
        </button>

        <button onClick={()=>onStory(STORIES[0])} className="w-full py-4 rounded-2xl font-bold text-white text-lg active:scale-95 transition-transform" style={{background:"linear-gradient(135deg,#4f46e5,#7c3aed)",boxShadow:"0 4px 24px rgba(99,102,241,.4)"}}>🌙 Start Bedtime Routine</button>
      </div>
    </div>
  </div>;
}

// Home
function Home({bed,name,onStory,onRoutine,favs,reads,streak,stars}){
  const tonight=STORIES[new Date().getDay()%STORIES.length];
  const h=new Date().getHours();
  const greet=h<12?"Good Morning":h<17?"Good Afternoon":"Good Evening";

  return <div className="flex-1 overflow-y-auto relative">
    {bed&&<Sky/>}
    <div className={`relative z-10 p-5 space-y-6 ${bed?"":"bg-gray-50"}`}>
      <div className="fadeUp flex items-center justify-between">
        <div>
          <p className={`text-lg ${bed?"text-gray-400":"text-gray-500"}`}>{greet}{name?`, ${name}`:""}</p>
          <h1 className="text-3xl font-bold"><span className={bed?"text-white":"text-gray-900"}>Little Lights </span><span style={{color:"#818cf8"}}>Bible Bedtime</span></h1>
        </div>
        <Lumi size={32} message={h>=18?"Sleepy time!":h>=12?"Story time!":"Good morning!"}/>
      </div>

      {/* Streak */}
      <div className={`flex items-center gap-3 p-4 rounded-2xl fadeUp d1 ${bed?"bg-white/[.04] glass":"bg-white shadow-sm"}`}>
        {[{e:"🔥",v:streak,l:"Streak"},{e:"⭐",v:stars,l:"Stars"},{e:"📖",v:reads.size+5,l:"Stories"}].map((s,i)=><>
          {i>0&&<div className={`w-px h-10 ${bed?"bg-gray-800":"bg-gray-100"}`}/>}
          <div key={s.l} className="text-center flex-1"><div className="text-xl">{s.e}</div><p className={`text-xl font-bold ${bed?"text-white":"text-gray-900"}`}>{s.v}</p><p className={`text-xs ${bed?"text-gray-600":"text-gray-400"}`}>{s.l}</p></div>
        </>)}
        <div className="text-xl">✅</div>
      </div>

      {/* Tonight */}
      <div className="fadeUp d2">
        <div className="flex items-center gap-2 mb-3"><span style={{color:"#818cf8"}}>✨</span><h2 className={`text-lg font-bold ${bed?"text-white":"text-gray-900"}`}>Tonight's Story</h2><span className="text-xs px-2 py-0.5 rounded-full font-bold" style={{background:"rgba(129,140,248,.15)",color:"#818cf8"}}>NEW</span></div>
        <button onClick={()=>onStory(tonight)} className="w-full text-left active:scale-[.98] transition-transform">
          <div className="relative h-48 rounded-3xl overflow-hidden" style={{background:`linear-gradient(135deg,${tonight.color}cc,#7c3aed)`}}>
            <div className="absolute inset-0 flex items-center justify-center text-8xl opacity-15">{tonight.emoji}</div>
            <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"/>
            <div className="absolute bottom-0 left-0 p-5">
              <div className="flex items-center gap-1 text-white/50 text-xs mb-1">🌙 Selected for tonight</div>
              <h3 className="text-2xl font-bold text-white">{tonight.title}</h3>
              <div className="flex gap-3 text-white/40 text-xs mt-1"><span>📖 {tonight.ref}</span><span>🎧 {tonight.dur} min</span></div>
            </div>
          </div>
        </button>
      </div>

      {/* Routine */}
      <button onClick={onRoutine} className={`w-full flex items-center gap-4 p-4 rounded-2xl text-left active:scale-[.98] transition-transform fadeUp d3 ${bed?"bg-white/[.04] glass":"bg-white shadow-sm"}`}>
        <div className="w-14 h-14 rounded-2xl flex items-center justify-center" style={{background:"linear-gradient(135deg,#4338ca,#7c3aed)",boxShadow:"0 4px 16px rgba(99,102,241,.3)"}}><span className="text-2xl">🛏️</span></div>
        <div className="flex-1"><p className={`font-bold ${bed?"text-white":"text-gray-900"}`}>Start Bedtime Routine</p><p className={`text-xs ${bed?"text-gray-500":"text-gray-400"}`}>Story + Breathing + Prayer + Sounds</p></div>
        <span className={bed?"text-gray-700":"text-gray-300"}>›</span>
      </button>

      {/* Categories */}
      <div className="fadeUp d4">
        <h2 className={`text-lg font-bold mb-3 ${bed?"text-white":"text-gray-900"}`}>Browse by Theme</h2>
        <div className="grid grid-cols-2 gap-3">{CATS.map(c=><div key={c.n} className="flex flex-col items-center justify-center h-20 rounded-2xl active:scale-95 transition-transform cursor-pointer" style={{background:c.bg}}>
          <span className="text-2xl">{c.i}</span><span className="text-white text-xs font-bold mt-1">{c.n}</span>
        </div>)}</div>
      </div>

      {/* Stories */}
      <div>
        <h2 className={`text-lg font-bold mb-3 ${bed?"text-white":"text-gray-900"}`}>All 50 Stories</h2>
        {STORIES.map((s,i)=><button key={s.id} onClick={()=>onStory(s)} className={`w-full flex items-center gap-3 p-3 rounded-2xl mb-2 text-left active:scale-[.98] transition-transform fadeUp ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`} style={{animationDelay:`${.3+i*.04}s`}}>
          <div className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl shrink-0" style={{background:`linear-gradient(135deg,${s.color}cc,#7c3aed)`}}>{s.emoji}</div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2"><p className={`font-bold text-sm ${bed?"text-white":"text-gray-900"}`}>{s.title}</p>{favs.has(s.id)&&<span className="text-xs">❤️</span>}{reads.has(s.id)&&<span className="text-xs">✅</span>}</div>
            <p className={`text-xs ${bed?"text-gray-500":"text-gray-400"}`}>{s.ref} · {s.cat} · {s.dur} min</p>
          </div>
          <span className={`text-xs px-2 py-1 rounded-full font-medium ${bed?"bg-white/[.06] text-white/40":"bg-gray-100 text-gray-500"}`}>{s.age}</span>
        </button>)}
      </div>
      <div className="h-4"/>
    </div>
  </div>;
}

// Library
function Library({bed,onStory,favs,reads}){
  const [filt,setFilt]=useState("All");
  const [q,setQ]=useState("");
  const list=STORIES.filter(s=>(filt==="All"||s.cat===filt)&&(!q||s.title.toLowerCase().includes(q.toLowerCase())));

  return <div className="flex-1 overflow-y-auto relative">
    {bed&&<Sky/>}
    <div className={`relative z-10 p-5 ${bed?"":"bg-gray-50"}`}>
      <div className={`flex items-center gap-2 p-3 rounded-2xl mb-4 ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
        <span className="text-gray-400 text-sm">🔍</span>
        <input value={q} onChange={e=>setQ(e.target.value)} placeholder="Search stories..." className={`flex-1 bg-transparent outline-none text-sm ${bed?"text-white":"text-gray-900"}`}/>
        {q&&<button onClick={()=>setQ("")} className="text-gray-500 text-xs active:text-white">✕</button>}
      </div>
      <div className="flex gap-2 mb-4 overflow-x-auto pb-1" style={{scrollbarWidth:"none"}}>
        {["All",...CATS.map(c=>c.n)].map(c=><button key={c} onClick={()=>setFilt(c)} className={`px-3 py-1.5 rounded-full text-xs font-bold whitespace-nowrap active:scale-95 transition-all`} style={{background:c===filt?"linear-gradient(135deg,#4f46e5,#7c3aed)":(bed?"rgba(255,255,255,.04)":"#f3f4f6"),color:c===filt?"white":"#9ca3af"}}>{c}</button>)}
      </div>
      <p className={`text-xs mb-3 ${bed?"text-gray-700":"text-gray-400"}`}>{list.length} stories</p>
      {list.map(s=><button key={s.id} onClick={()=>onStory(s)} className={`w-full flex items-center gap-3 p-3 rounded-2xl mb-2 text-left active:scale-[.98] transition-transform ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
        <div className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl shrink-0" style={{background:`linear-gradient(135deg,${s.color}cc,#7c3aed)`}}>{s.emoji}</div>
        <div className="flex-1">
          <div className="flex items-center gap-2"><p className={`font-bold text-sm ${bed?"text-white":"text-gray-900"}`}>{s.title}</p>{favs.has(s.id)&&<span className="text-xs">❤️</span>}{reads.has(s.id)&&<span className="text-xs">✅</span>}</div>
          <p className={`text-xs ${bed?"text-gray-500":"text-gray-400"}`}>{s.ref} · {s.cat} · {s.dur} min</p>
        </div>
        <span className={`text-xs px-2 py-1 rounded-full font-medium ${bed?"bg-white/[.06] text-white/40":"bg-gray-100 text-gray-500"}`}>{s.age}</span>
      </button>)}
      {!list.length&&<div className="text-center py-16"><span className="text-5xl">📖</span><p className={`mt-3 font-bold ${bed?"text-white":"text-gray-900"}`}>No stories found</p></div>}
    </div>
  </div>;
}

// Favorites
function Favs({bed,favs,onStory}){
  const list=STORIES.filter(s=>favs.has(s.id));
  return <div className="flex-1 overflow-y-auto relative">
    {bed&&<Sky/>}
    <div className={`relative z-10 p-5 ${bed?"":"bg-gray-50"}`}>
      {!list.length?<div className="flex flex-col items-center justify-center py-20">
        <span className="text-6xl mb-4">❤️</span>
        <p className={`font-bold text-lg ${bed?"text-white":"text-gray-900"}`}>No Favorites Yet</p>
        <p className={`text-sm mt-1 ${bed?"text-gray-500":"text-gray-400"}`}>Tap the heart on any story</p>
      </div>:list.map(s=><button key={s.id} onClick={()=>onStory(s)} className={`w-full flex items-center gap-3 p-3 rounded-2xl mb-2 text-left active:scale-[.98] transition-transform ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
        <div className="w-14 h-14 rounded-xl flex items-center justify-center text-2xl shrink-0" style={{background:`linear-gradient(135deg,${s.color}cc,#7c3aed)`}}>{s.emoji}</div>
        <div className="flex-1"><p className={`font-bold text-sm ${bed?"text-white":"text-gray-900"}`}>{s.title}</p><p className={`text-xs ${bed?"text-gray-500":"text-gray-400"}`}>{s.ref} · {s.dur} min</p></div>
        <span className="text-lg">❤️</span>
      </button>)}
    </div>
  </div>;
}

// Rewards + Collection
function Rewards({bed,reads,streak,stars,collected}){
  return <div className="flex-1 overflow-y-auto relative">
    {bed&&<Sky/>}
    <div className={`relative z-10 p-5 space-y-6 ${bed?"":"bg-gray-50"}`}>
      <div className="flex flex-col items-center pt-2 fadeUp">
        <div className="relative"><div className="w-24 h-24 rounded-full flex items-center justify-center" style={{background:"radial-gradient(circle,rgba(250,204,21,.15),rgba(250,204,21,.03)"}}><span className="text-5xl" style={{animation:"glow 2s infinite"}}>⭐</span></div></div>
        <p className={`text-5xl font-bold mt-3 ${bed?"text-white":"text-gray-900"}`}>{stars}</p>
        <p className={`text-lg ${bed?"text-gray-400":"text-gray-500"}`}>Sleep Stars</p>
      </div>

      <div className={`flex p-4 rounded-2xl fadeUp d1 ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
        {[{i:"🔥",v:streak,l:"Streak"},{i:"🏆",v:Math.max(streak,3),l:"Best"},{i:"📖",v:reads.size+5,l:"Total"}].map((s,i)=><div key={s.l} className={`flex-1 text-center ${i<2?`border-r ${bed?"border-gray-800/50":"border-gray-100"}`:""}`}>
          <div className="text-xl">{s.i}</div><p className={`text-2xl font-bold ${bed?"text-white":"text-gray-900"}`}>{s.v}</p><p className={`text-xs ${bed?"text-gray-600":"text-gray-400"}`}>{s.l}</p>
        </div>)}
      </div>

      {/* Collectibles */}
      <div className="fadeUp d2">
        <h2 className={`text-lg font-bold mb-3 ${bed?"text-white":"text-gray-900"}`}>Collection</h2>
        <div className="flex gap-3 overflow-x-auto pb-2" style={{scrollbarWidth:"none"}}>
          {COLLECTIBLES.map(c=>{const has=collected.has(c.id);return <div key={c.id} className={`shrink-0 w-20 flex flex-col items-center py-3 rounded-2xl ${has?"":`opacity-30`} ${bed?"bg-white/[.04]":"bg-gray-100"}`}>
            <span className="text-3xl mb-1">{c.emoji}</span>
            <span className={`text-xs font-bold ${bed?"text-white":"text-gray-700"}`}>{c.name}</span>
            {has&&<span className="text-green-400 text-xs mt-0.5">✓</span>}
          </div>;})}
        </div>
      </div>

      {/* Badges */}
      <div className="fadeUp d3">
        <h2 className={`text-lg font-bold mb-4 ${bed?"text-white":"text-gray-900"}`}>Badges</h2>
        <div className="grid grid-cols-3 gap-4">{BADGES.map((b,i)=>{const e=i<3;return <div key={b.id} className={`flex flex-col items-center ${e?"":"opacity-25"}`}>
          <div className={`w-16 h-16 rounded-full flex items-center justify-center text-2xl ${e?"shadow-lg":""}`} style={{background:e?"linear-gradient(135deg,#facc15,#f97316)":(bed?"rgba(255,255,255,.04)":"#f3f4f6")}}>
            {b.icon}
          </div>
          <p className={`text-xs font-bold mt-2 text-center ${bed?"text-white":"text-gray-700"}`}>{b.name}</p>
        </div>;})}</div>
      </div>
      <div className="h-4"/>
    </div>
  </div>;
}

// Settings
function Settings({bed,onToggle,onDash}){
  return <div className={`flex-1 overflow-y-auto ${bed?"bg-[#070714]":"bg-gray-50"}`}>
    <div className="p-5 space-y-1">
      {[["Display",[
        {type:"toggle",icon:"🌙",label:"Bedtime Mode",active:bed,onTap:onToggle},
        {type:"slider",icon:"🔤",label:"Font Size",val:.4},
      ]],["Playback",[
        {type:"toggle",icon:"▶️",label:"Auto-play Narration"},
        {type:"slider",icon:"🔊",label:"Narration Volume",val:.75},
        {type:"slider",icon:"🎵",label:"Ambient Volume",val:.33},
      ]],["For Parents",[
        {type:"link",icon:"📊",label:"Parent Dashboard",onTap:onDash},
      ]],["About",[
        {type:"link",icon:"🔒",label:"Privacy Policy"},
        {type:"link",icon:"📄",label:"Terms of Use"},
        {type:"link",icon:"✉️",label:"Support"},
      ]]].map(([title,items])=><div key={title}>
        <h3 className={`text-xs font-bold uppercase px-3 pt-5 pb-2 tracking-widest ${bed?"text-gray-600":"text-gray-400"}`}>{title}</h3>
        <div className={`rounded-2xl overflow-hidden ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
          {items.map((it,i)=><div key={it.label} className={`p-4 flex items-center gap-3 ${i>0?`border-t ${bed?"border-gray-800/30":"border-gray-100"}`:""}`}>
            <span>{it.icon}</span>
            <span className={`text-sm font-medium flex-1 ${bed?"text-white":"text-gray-900"}`}>{it.label}</span>
            {it.type==="toggle"&&<button onClick={it.onTap} className={`w-12 h-7 rounded-full relative transition-colors ${it.active||bed&&it.label==="Bedtime Mode"?"bg-indigo-500":"bg-gray-300"}`}><div className={`absolute top-1 w-5 h-5 rounded-full bg-white shadow-sm transition-all ${it.active||bed&&it.label==="Bedtime Mode"?"left-6":"left-1"}`}/></button>}
            {it.type==="slider"&&<div className={`w-24 h-1.5 rounded-full ${bed?"bg-white/[.06]":"bg-gray-200"}`}><div className="h-full rounded-full bg-indigo-500" style={{width:`${(it.val||.5)*100}%`}}/></div>}
            {it.type==="link"&&<button onClick={it.onTap} className={`${bed?"text-gray-600":"text-gray-300"}`}>›</button>}
          </div>)}
        </div>
      </div>)}
      <div className={`text-center pt-8 pb-6 ${bed?"text-gray-700":"text-gray-400"}`}>
        <p className="text-xs font-bold">Little Lights Bible Bedtime</p>
        <p className="text-xs">Version 3.0 — Free for all families</p>
        <p className="text-xs mt-0.5">Made with ❤️ for families everywhere</p>
      </div>
    </div>
  </div>;
}

// Parent Dashboard
function Dash({bed,onBack,reads,streak,stars}){
  const [tip,setTip]=useState(0);
  const TIPS=[{i:"🌙",t:"Start bedtime stories at the same time each night."},{i:"🌬️",t:"Try breathing exercises to help your child relax."},{i:"🔊",t:"Ambient sounds help children fall asleep faster."},{i:"⏱",t:"Sleep timer gently fades audio for natural sleep."},{i:"📱",t:"Use Bedtime Mode 30 min before sleep."}];

  return <div className="h-full flex flex-col relative">
    {bed&&<Sky/>}
    <div className={`relative z-10 flex-1 overflow-y-auto ${bed?"":"bg-gray-50"}`}>
      <div className="flex items-center px-4 py-3"><button onClick={onBack} className={`text-sm ${bed?"text-white/40":"text-gray-500"} active:opacity-70`}>← Back</button><p className={`flex-1 text-center font-bold ${bed?"text-white":"text-gray-900"}`}>Parent Dashboard</p><div className="w-12"/></div>
      <div className="p-5 space-y-5">
        <div className={`p-4 rounded-2xl ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
          <h3 className={`font-bold text-sm mb-4 ${bed?"text-white":"text-gray-900"}`}>📅 This Week</h3>
          <div className="flex gap-2">{["S","M","T","W","T","F","S"].map((d,i)=><div key={d+i} className="flex-1 flex flex-col items-center gap-1.5">
            <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold`} style={{background:i<streak?"linear-gradient(135deg,#6366f1,#7c3aed)":(bed?"rgba(255,255,255,.04)":"#f3f4f6"),color:i<streak?"white":"#6b7280"}}>{i<streak?"✓":""}</div>
            <span className={`text-xs ${bed?"text-gray-600":"text-gray-400"}`}>{d}</span>
          </div>)}</div>
        </div>

        <div className={`p-4 rounded-2xl ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
          <h3 className={`font-bold text-sm mb-3 ${bed?"text-white":"text-gray-900"}`}>📊 Reading Consistency</h3>
          <div className="flex justify-between text-sm mb-2"><span className={bed?"text-gray-400":"text-gray-500"}>Overall</span><span className={`font-bold ${bed?"text-white":"text-gray-900"}`}>{Math.round(streak/7*100)}%</span></div>
          <div className={`h-3 rounded-full overflow-hidden ${bed?"bg-white/[.06]":"bg-gray-100"}`}><div className="h-full rounded-full transition-all duration-700" style={{width:`${streak/7*100}%`,background:"linear-gradient(90deg,#22c55e,#6366f1)"}}/></div>
        </div>

        <div className={`p-4 rounded-2xl ${bed?"bg-white/[.04]":"bg-white shadow-sm"}`}>
          <h3 className={`font-bold text-sm mb-3 ${bed?"text-white":"text-gray-900"}`}>💡 Sleep Tip</h3>
          <div className="flex gap-3"><span className="text-2xl">{TIPS[tip%TIPS.length].i}</span><p className={`text-sm leading-relaxed ${bed?"text-gray-400":"text-gray-500"}`}>{TIPS[tip%TIPS.length].t}</p></div>
          <button onClick={()=>setTip(tip+1)} className="mt-3 text-xs font-bold" style={{color:"#818cf8"}}>Next Tip →</button>
        </div>
        <div className="h-4"/>
      </div>
    </div>
  </div>;
}

/* ━━━━━━━━━━━━━━━ MAIN ━━━━━━━━━━━━━━━ */
export default function App(){
  const [scr,setScr]=useState("onboard");
  const [tab,setTab]=useState("home");
  const [bed,setBed]=useState(true);
  const [story,setStory]=useState(null);
  const [sub,setSub]=useState(null);
  const [name,setName]=useState("");
  const [favs,setFavs]=useState(new Set());
  const [reads,setReads]=useState(new Set());
  const [collected,setCollected]=useState(new Set());
  const streak=3;
  const stars=reads.size+7;

  const toggleFav=id=>setFavs(f=>{const n=new Set(f);n.has(id)?n.delete(id):n.add(id);return n;});
  const markRead=id=>{setReads(r=>new Set(r).add(id));const c=COLLECTIBLES.find(x=>x.story===id);if(c)setCollected(s=>new Set(s).add(c.id));};
  const goStory=s=>{setStory(s);setScr("story");};
  const goBack=()=>{setScr("app");setSub(null);};

  const tabs=[{id:"home",i:"🌙",l:"Home"},{id:"library",i:"📚",l:"Library"},{id:"favorites",i:"❤️",l:"Favorites"},{id:"rewards",i:"⭐",l:"Rewards"},{id:"settings",i:"⚙️",l:"Settings"}];

  const content=()=>{
    if(scr==="onboard") return <Onboarding onDone={n=>{setName(n);setScr("app");}}/>;
    if(scr==="story") return <StoryDetail story={story} bed={bed} onBack={goBack} favs={favs} toggleFav={toggleFav} markRead={markRead} reads={reads} collected={collected}/>;
    if(sub==="routine") return <Routine bed={bed} onBack={()=>setSub(null)} onStory={goStory}/>;
    if(sub==="dash") return <Dash bed={bed} onBack={()=>setSub(null)} reads={reads} streak={streak} stars={stars}/>;
    switch(tab){
      case"home":return <Home bed={bed} name={name} onStory={goStory} onRoutine={()=>setSub("routine")} favs={favs} reads={reads} streak={streak} stars={stars}/>;
      case"library":return <Library bed={bed} onStory={goStory} favs={favs} reads={reads}/>;
      case"favorites":return <Favs bed={bed} favs={favs} onStory={goStory}/>;
      case"rewards":return <Rewards bed={bed} reads={reads} streak={streak} stars={stars} collected={collected}/>;
      case"settings":return <Settings bed={bed} onToggle={()=>setBed(!bed)} onDash={()=>setSub("dash")}/>;
    }
  };

  return<>
    <style>{CSS}</style>
    <div className="w-full h-screen flex justify-center" style={{background:"#0a0a0a"}}>
      <div className="w-full max-w-sm h-full flex flex-col relative overflow-hidden" style={{background:bed?"#070714":"#f9fafb"}}>
        {scr==="app"&&!sub&&<div className={`flex items-center justify-between px-6 py-2 text-xs font-bold relative z-20 ${bed?"text-white/30":"text-gray-400"}`}><span>9:41</span><div className="flex items-center gap-1.5"><span style={{fontSize:10}}>📶</span><span style={{fontSize:10}}>🔋</span></div></div>}
        <div className="flex-1 flex flex-col overflow-hidden relative">{content()}</div>
        {scr==="app"&&!sub&&<div className={`flex relative z-20 ${bed?"bg-[#0c0b1a]/95 border-t border-gray-800/30":"bg-white/95 border-t border-gray-200"} glass`}>
          {tabs.map(t=><button key={t.id} onClick={()=>setTab(t.id)} className={`flex-1 flex flex-col items-center py-2.5 gap-0.5 transition-colors ${tab===t.id?(bed?"text-indigo-400":"text-indigo-600"):(bed?"text-gray-700":"text-gray-400")}`}>
            <span className="text-lg">{t.i}</span><span className="text-xs font-medium">{t.l}</span>
            {tab===t.id&&<div className="w-1 h-1 rounded-full" style={{background:bed?"#818cf8":"#4f46e5"}}/>}
          </button>)}
        </div>}
      </div>
    </div>
  </>;
}
