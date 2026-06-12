import Foundation

// MARK: - Game content
// All hand-written, kid-level, and rooted in the stories the app tells.
// Keep additions unambiguous and gentle (no trick questions, no sting),
// and follow the copy rules in CLAUDE.md.
//
// Every bank below covers ALL 50 stories (quiz and true/false carry six
// entries per story; riddles, scrambles, and builder verses one each), so
// each game has at least 50 distinct versions. Rounds are dealt through
// GameDeck (bottom of this file), which guarantees the next round never
// repeats the one just played.

// MARK: Game stars (shared reward currency for the Games tab)

enum GameStars {
    static let key = "games.totalStars"

    /// Adds stars to the device-wide Games total (shown on the hub).
    static func award(_ count: Int) {
        guard count > 0 else { return }
        let defaults = UserDefaults.standard
        defaults.set(defaults.integer(forKey: key) + count, forKey: key)
    }
}

// MARK: Story Quiz (6 questions per story x 50 stories)

struct QuizQuestion {
    let prompt: String
    let choices: [String]
    let answerIndex: Int

    static let bank: [QuizQuestion] = [
        // story: noah-big-boat
        QuizQuestion(prompt: "What did God tell Noah to build?", choices: ["A big boat called an ark", "A tall tower", "A little house"], answerIndex: 0),
        QuizQuestion(prompt: "Who came onto the ark two by two?", choices: ["The neighbors", "The animals", "The fish"], answerIndex: 1),
        QuizQuestion(prompt: "What fell from the sky?", choices: ["Snow", "Leaves", "Rain"], answerIndex: 2),
        QuizQuestion(prompt: "Where was Noah's family during the storm?", choices: ["On a mountain", "Safe inside the ark", "In a tent"], answerIndex: 1),
        QuizQuestion(prompt: "What did God put in the sky as a promise?", choices: ["A rainbow", "A cloud", "A kite"], answerIndex: 0),
        QuizQuestion(prompt: "How did Noah feel when they stepped onto dry land?", choices: ["Grumpy", "Sleepy", "Thankful"], answerIndex: 2),
        // story: daniel-and-the-lions
        QuizQuestion(prompt: "What did Daniel do every day?", choices: ["He prayed to God", "He baked bread", "He sailed boats"], answerIndex: 0),
        QuizQuestion(prompt: "Why did the men make the new law?", choices: ["They wanted a holiday", "They were jealous of Daniel", "They liked lions"], answerIndex: 1),
        QuizQuestion(prompt: "Where was Daniel put for praying to God?", choices: ["A tall tower", "A deep well", "The lions' den"], answerIndex: 2),
        QuizQuestion(prompt: "Who could not sleep that night?", choices: ["The king", "Daniel", "The lions"], answerIndex: 0),
        QuizQuestion(prompt: "Who shut the mouths of the lions?", choices: ["A brave soldier", "God's angel", "The king"], answerIndex: 1),
        QuizQuestion(prompt: "What happened to Daniel in the den?", choices: ["He hurt his arm", "He ran away", "He was kept safe all night"], answerIndex: 2),
        // story: jesus-calms-the-storm
        QuizQuestion(prompt: "What was Jesus doing when the storm began?", choices: ["Fishing", "Sleeping in the boat", "Rowing"], answerIndex: 1),
        QuizQuestion(prompt: "Where were Jesus and His friends going?", choices: ["Across the lake", "Up a mountain", "To the market"], answerIndex: 0),
        QuizQuestion(prompt: "What did Jesus say to the storm?", choices: ["\"Go away!\"", "\"Be louder!\"", "\"Peace, be still.\""], answerIndex: 2),
        QuizQuestion(prompt: "What happened when Jesus spoke?", choices: ["The storm got bigger", "The boat tipped over", "The wind and waves became calm"], answerIndex: 2),
        QuizQuestion(prompt: "How did the disciples feel during the storm?", choices: ["Afraid", "Hungry", "Sleepy"], answerIndex: 0),
        QuizQuestion(prompt: "What obeyed Jesus that day?", choices: ["The seagulls", "The wind and the waves", "The fish"], answerIndex: 1),
        // story: the-lost-sheep
        QuizQuestion(prompt: "How many sheep did the shepherd have?", choices: ["Ten", "Fifty", "One hundred"], answerIndex: 2),
        QuizQuestion(prompt: "What did one little sheep do?", choices: ["It wandered away", "It fell asleep", "It learned to swim"], answerIndex: 0),
        QuizQuestion(prompt: "What did the shepherd do about his lost sheep?", choices: ["He waited at home", "He searched until he found it", "He forgot about it"], answerIndex: 1),
        QuizQuestion(prompt: "How did the shepherd carry the sheep home?", choices: ["With a smile and joy", "With a grumble", "In a wagon"], answerIndex: 0),
        QuizQuestion(prompt: "What did the shepherd say to his friends?", choices: ["\"I am tired!\"", "\"Rejoice with me!\"", "\"Stay away!\""], answerIndex: 1),
        QuizQuestion(prompt: "Who is like the good shepherd in this story?", choices: ["The wolf", "The sheep", "God"], answerIndex: 2),
        // story: the-birth-of-jesus
        QuizQuestion(prompt: "What town did Mary and Joseph travel to?", choices: ["Bethlehem", "Nineveh", "Jericho"], answerIndex: 0),
        QuizQuestion(prompt: "Where did Mary lay baby Jesus?", choices: ["In a soft bed", "In a manger", "In a basket"], answerIndex: 1),
        QuizQuestion(prompt: "Who told the shepherds the good news?", choices: ["A king", "A friend", "An angel"], answerIndex: 2),
        QuizQuestion(prompt: "What were the shepherds doing at night?", choices: ["Baking bread", "Watching their sheep", "Playing games"], answerIndex: 1),
        QuizQuestion(prompt: "What did the angel tell the shepherds not to be?", choices: ["Afraid", "Sleepy", "Late"], answerIndex: 0),
        QuizQuestion(prompt: "What did the shepherds do after the angels' news?", choices: ["They went back to sleep", "They counted their sheep", "They hurried to see baby Jesus"], answerIndex: 2),
        // story: david-and-goliath
        QuizQuestion(prompt: "Who was the giant warrior?", choices: ["Pharaoh", "Goliath", "Samson"], answerIndex: 1),
        QuizQuestion(prompt: "What did David take instead of heavy armor?", choices: ["A sling and smooth stones", "A big sword", "A heavy shield"], answerIndex: 0),
        QuizQuestion(prompt: "What did David take care of before?", choices: ["Horses", "Camels", "Sheep"], answerIndex: 2),
        QuizQuestion(prompt: "Who did David say the battle belonged to?", choices: ["The king", "The Lord", "His brothers"], answerIndex: 1),
        QuizQuestion(prompt: "How many stones did it take to win?", choices: ["One", "Five", "Ten"], answerIndex: 0),
        QuizQuestion(prompt: "What did David remember about God?", choices: ["God was far away", "God was sleepy", "God was bigger than the giant"], answerIndex: 2),
        // story: jonah-and-the-big-fish
        QuizQuestion(prompt: "Where did God tell Jonah to go?", choices: ["Bethlehem", "Egypt", "Nineveh"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jonah do instead of obeying?", choices: ["He got on a ship and ran away", "He hid in a cave", "He took a nap"], answerIndex: 0),
        QuizQuestion(prompt: "What did God send to keep Jonah safe?", choices: ["A dolphin", "A great fish", "A boat"], answerIndex: 1),
        QuizQuestion(prompt: "What did Jonah do inside the fish?", choices: ["He prayed and said he was sorry", "He went fishing", "He counted stars"], answerIndex: 0),
        QuizQuestion(prompt: "How many days was Jonah inside the fish?", choices: ["One", "Seven", "Three"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jonah do when he reached dry land?", choices: ["He hid again", "He went to Nineveh", "He built a house"], answerIndex: 1),
        // story: baby-moses
        QuizQuestion(prompt: "Where did Moses' mother place his basket?", choices: ["In a tree", "Among the reeds by the river", "Under the bed"], answerIndex: 1),
        QuizQuestion(prompt: "Who watched the basket nearby?", choices: ["His big sister", "His grandpa", "A shepherd"], answerIndex: 0),
        QuizQuestion(prompt: "Who found baby Moses in the basket?", choices: ["A fisherman", "A queen from far away", "Pharaoh's daughter"], answerIndex: 2),
        QuizQuestion(prompt: "How did Pharaoh's daughter feel about the baby?", choices: ["Angry", "She felt compassion for him", "Scared"], answerIndex: 1),
        QuizQuestion(prompt: "Who got to help care for baby Moses?", choices: ["His own mother", "A kind soldier", "Nobody"], answerIndex: 0),
        QuizQuestion(prompt: "Who watched over baby Moses from the beginning?", choices: ["The river", "The reeds", "God"], answerIndex: 2),
        // story: the-good-samaritan
        QuizQuestion(prompt: "What happened to the man on the road?", choices: ["Robbers hurt him", "He got lost", "He fell asleep"], answerIndex: 0),
        QuizQuestion(prompt: "What did the first people who passed by do?", choices: ["They sang to him", "They did not stop to help", "They called a doctor"], answerIndex: 1),
        QuizQuestion(prompt: "Who stopped to help the hurt man?", choices: ["A king", "A robber", "A Samaritan"], answerIndex: 2),
        QuizQuestion(prompt: "How did the Samaritan carry the hurt man?", choices: ["On his animal", "On his back", "In a cart"], answerIndex: 0),
        QuizQuestion(prompt: "What did the Samaritan pay for?", choices: ["A new coat", "The man's care", "A big dinner"], answerIndex: 1),
        QuizQuestion(prompt: "Why did Jesus tell this story?", choices: ["To make people laugh", "To teach about boats", "To show what love looks like"], answerIndex: 2),
        // story: creation-story
        QuizQuestion(prompt: "What did God say first?", choices: ["\"Let there be light\"", "\"Let it rain\"", "\"Time for bed\""], answerIndex: 0),
        QuizQuestion(prompt: "What did God make for the night?", choices: ["The sun", "The moon and stars", "Lanterns"], answerIndex: 1),
        QuizQuestion(prompt: "What did God make to fly?", choices: ["Fish", "Bunnies", "Birds"], answerIndex: 2),
        QuizQuestion(prompt: "Who did God make in His image?", choices: ["The animals", "People", "The trees"], answerIndex: 1),
        QuizQuestion(prompt: "What did God say about everything He made?", choices: ["It was very good", "It was too big", "It needed more color"], answerIndex: 0),
        QuizQuestion(prompt: "Who made the heavens and the earth?", choices: ["The sun", "The angels", "God"], answerIndex: 2),
        // story: joseph-and-his-colorful-coat
        QuizQuestion(prompt: "Who gave Joseph his colorful coat?", choices: ["His brothers", "His father", "A king"], answerIndex: 1),
        QuizQuestion(prompt: "How did Joseph's brothers feel about his coat?", choices: ["Jealous", "Sleepy", "Proud of him"], answerIndex: 0),
        QuizQuestion(prompt: "Who never left Joseph, even far from home?", choices: ["His brothers", "A shepherd", "God"], answerIndex: 2),
        QuizQuestion(prompt: "What did God give Joseph in hard places?", choices: ["A new coat", "Wisdom and help", "A boat"], answerIndex: 1),
        QuizQuestion(prompt: "When Joseph got an important job, what could he do?", choices: ["Hide away", "Build a tower", "Help many people"], answerIndex: 2),
        QuizQuestion(prompt: "What did Joseph do for the brothers who hurt him?", choices: ["He helped them", "He ran away", "He hid his coat"], answerIndex: 0),
        // story: the-wise-men
        QuizQuestion(prompt: "What did the wise men see in the sky?", choices: ["A rainbow", "A kite", "A special star"], answerIndex: 2),
        QuizQuestion(prompt: "What did the special star mean?", choices: ["A great King was born", "A storm was coming", "It was breakfast time"], answerIndex: 0),
        QuizQuestion(prompt: "Where did the star lead the wise men?", choices: ["To a big ship", "To Jesus", "To a desert cave"], answerIndex: 1),
        QuizQuestion(prompt: "What did the wise men do when they found Jesus?", choices: ["They fell asleep", "They flew kites", "They bowed and worshiped Him"], answerIndex: 2),
        QuizQuestion(prompt: "What did the wise men give Jesus?", choices: ["Precious gifts", "A puppy", "A new star"], answerIndex: 0),
        QuizQuestion(prompt: "How did the wise men feel when they found Jesus?", choices: ["Grumpy", "Full of joy", "Bored"], answerIndex: 1),
        // story: christmas-the-birth-of-jesus
        QuizQuestion(prompt: "Where did Mary and Joseph rest that holy night?", choices: ["In a simple stable", "In a castle", "On a boat"], answerIndex: 0),
        QuizQuestion(prompt: "Where did Mary lay baby Jesus?", choices: ["In a treehouse", "In a manger", "In a wagon"], answerIndex: 1),
        QuizQuestion(prompt: "Who watched their sheep under the night sky?", choices: ["Wise men", "Fishermen", "Shepherds"], answerIndex: 2),
        QuizQuestion(prompt: "Who told the shepherds the wonderful news?", choices: ["Angels", "A donkey", "The wise men"], answerIndex: 0),
        QuizQuestion(prompt: "What was the angels' wonderful news?", choices: ["A new star had a name", "The Savior had been born", "Snow was coming"], answerIndex: 1),
        QuizQuestion(prompt: "What did the shepherds do after hearing the news?", choices: ["Went back to sleep", "Counted their sheep", "Hurried to see Jesus"], answerIndex: 2),
        // story: zacchaeus
        QuizQuestion(prompt: "Why did Zacchaeus climb a tree?", choices: ["To pick apples", "To see Jesus", "To take a nap"], answerIndex: 1),
        QuizQuestion(prompt: "Why couldn't Zacchaeus see over the people?", choices: ["It was too dark", "It was raining", "He was small and the crowd was big"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jesus do when He came by the tree?", choices: ["Called Zacchaeus by name", "Kept on walking", "Climbed up too"], answerIndex: 0),
        QuizQuestion(prompt: "Where did Jesus go with Zacchaeus?", choices: ["To the market", "To Zacchaeus' home", "To the sea"], answerIndex: 1),
        QuizQuestion(prompt: "How did Zacchaeus' heart begin to change?", choices: ["He wanted to make things right", "He wanted a taller tree", "He wanted to hide"], answerIndex: 0),
        QuizQuestion(prompt: "What does this story remind us?", choices: ["Trees are good for climbing", "Crowds are very loud", "Jesus notices every person"], answerIndex: 2),
        // story: feeding-the-five-thousand
        QuizQuestion(prompt: "Who shared his five loaves and two fish?", choices: ["A king", "A shepherd", "A little boy"], answerIndex: 2),
        QuizQuestion(prompt: "How many loaves of bread did the boy have?", choices: ["Five", "Two", "Ten"], answerIndex: 0),
        QuizQuestion(prompt: "How many fish did the boy have?", choices: ["Five", "Two", "Seven"], answerIndex: 1),
        QuizQuestion(prompt: "What did Jesus do before sharing the food?", choices: ["Took a nap", "Thanked God", "Caught more fish"], answerIndex: 1),
        QuizQuestion(prompt: "How much food was there after Jesus shared it?", choices: ["Only crumbs", "Just enough for one", "Enough for everyone, with leftovers"], answerIndex: 2),
        QuizQuestion(prompt: "Why had the big crowd gathered?", choices: ["To hear Jesus", "To go fishing", "To build a wall"], answerIndex: 0),
        // story: jesus-loves-the-children
        QuizQuestion(prompt: "Why did families bring children to Jesus?", choices: ["So He could bless them", "To go swimming", "To buy bread"], answerIndex: 0),
        QuizQuestion(prompt: "What did some grown-ups try to do?", choices: ["Sing songs", "Bring snacks", "Send the children away"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jesus say?", choices: ["\"Everyone go home\"", "\"Let the little children come to Me\"", "\"Wait until morning\""], answerIndex: 1),
        QuizQuestion(prompt: "How did Jesus feel about sending the children away?", choices: ["He did not like it", "He thought it was fine", "He did not notice"], answerIndex: 0),
        QuizQuestion(prompt: "What did Jesus do with the children?", choices: ["Sent them fishing", "Told them to be quiet", "Held them close and blessed them"], answerIndex: 2),
        QuizQuestion(prompt: "Who matters deeply to God?", choices: ["Only grown-ups", "Children", "Only kings"], answerIndex: 1),
        // story: the-prodigal-son
        QuizQuestion(prompt: "Who told the story of the prodigal son?", choices: ["Moses", "Jesus", "Joshua"], answerIndex: 1),
        QuizQuestion(prompt: "Where did the son choose to go?", choices: ["Far away from home", "To the next field", "Out fishing"], answerIndex: 0),
        QuizQuestion(prompt: "What did the son realize after a while?", choices: ["He needed a new coat", "He liked it far away", "He had made wrong choices"], answerIndex: 2),
        QuizQuestion(prompt: "What did the father do when he saw his son far off?", choices: ["Closed the door", "Ran to him with joy", "Hid inside"], answerIndex: 1),
        QuizQuestion(prompt: "What happened when the son came home?", choices: ["A big hug and a celebration", "A long wait outside", "Nothing at all"], answerIndex: 0),
        QuizQuestion(prompt: "Why did Jesus tell this story?", choices: ["To talk about farming", "To describe a long trip", "To show how forgiving God is"], answerIndex: 2),
        // story: esthers-courage
        QuizQuestion(prompt: "What was Esther?", choices: ["A shepherd", "A fisher", "A queen"], answerIndex: 2),
        QuizQuestion(prompt: "Who was in danger?", choices: ["The king's horses", "Esther's people", "The palace garden"], answerIndex: 1),
        QuizQuestion(prompt: "How did Esther feel before she spoke up?", choices: ["Afraid, but trusting God", "Sleepy", "Silly"], answerIndex: 0),
        QuizQuestion(prompt: "What did Esther do with courage?", choices: ["Hid in the palace", "Ran far away", "Stepped forward and spoke up"], answerIndex: 2),
        QuizQuestion(prompt: "What did God use Esther's bravery to do?", choices: ["Build a wall", "Protect many people", "Find a star"], answerIndex: 1),
        QuizQuestion(prompt: "What does courage mean in Esther's story?", choices: ["Trusting God enough to do what is right", "Never feeling afraid", "Being the loudest"], answerIndex: 0),
        // story: joshua-and-jericho
        QuizQuestion(prompt: "Who gave Joshua the unusual plan?", choices: ["God", "A soldier", "The king of Jericho"], answerIndex: 0),
        QuizQuestion(prompt: "What did God tell the people to do?", choices: ["Build a ladder", "March around the city", "Dig a tunnel"], answerIndex: 1),
        QuizQuestion(prompt: "How long did the people march?", choices: ["One hour", "Just one morning", "Several days"], answerIndex: 2),
        QuizQuestion(prompt: "What did the people do at the right moment?", choices: ["They shouted", "They whispered", "They went home"], answerIndex: 0),
        QuizQuestion(prompt: "What happened to the walls of Jericho?", choices: ["They grew taller", "They turned blue", "God made them fall"], answerIndex: 2),
        QuizQuestion(prompt: "What did Joshua learn?", choices: ["Marching is tiring", "God's way is wise, even when surprising", "Walls are very strong"], answerIndex: 1),
        // story: elijah-and-the-whisper
        QuizQuestion(prompt: "How did Elijah feel after his hard time?", choices: ["Excited", "Tired and discouraged", "Hungry for cake"], answerIndex: 1),
        QuizQuestion(prompt: "How did God first care for Elijah?", choices: ["Sent a parade", "Gave him a crown", "Gently gave him rest"], answerIndex: 2),
        QuizQuestion(prompt: "Was God in the strong wind?", choices: ["No", "Yes", "Only a little"], answerIndex: 0),
        QuizQuestion(prompt: "What came after the wind and the earthquake?", choices: ["A flood", "A fire", "A rainbow"], answerIndex: 1),
        QuizQuestion(prompt: "Where did God meet Elijah?", choices: ["In a soft gentle whisper", "In the loud fire", "In the earthquake"], answerIndex: 0),
        QuizQuestion(prompt: "What does Elijah's story remind us at bedtime?", choices: ["Storms last forever", "Whispers are loud", "God is near in quiet moments"], answerIndex: 2),
        // story: the-boy-samuel
        QuizQuestion(prompt: "Who heard his name being called at night?", choices: ["Eli", "Samuel", "Moses"], answerIndex: 1),
        QuizQuestion(prompt: "Who did Samuel go to when he heard the voice?", choices: ["Eli", "His mother", "A shepherd"], answerIndex: 0),
        QuizQuestion(prompt: "Who was really calling Samuel's name?", choices: ["Eli", "A little bird", "God"], answerIndex: 2),
        QuizQuestion(prompt: "What was Samuel doing when he heard his name?", choices: ["Eating breakfast", "Lying down to sleep", "Playing outside"], answerIndex: 1),
        QuizQuestion(prompt: "What did Samuel say to God?", choices: ["\"Speak, Lord, I'm listening\"", "\"Please come back later\"", "\"I'm too sleepy\""], answerIndex: 0),
        QuizQuestion(prompt: "What did Samuel learn that night?", choices: ["He could run very fast", "Eli was a king", "God knew his name"], answerIndex: 2),
        // story: abraham-and-the-stars
        QuizQuestion(prompt: "What did Abraham look up at one night?", choices: ["The stars", "The sea", "A mountain"], answerIndex: 0),
        QuizQuestion(prompt: "Why was Abraham's heart a little sad?", choices: ["He lost his sheep", "He had no children", "He was hungry"], answerIndex: 1),
        QuizQuestion(prompt: "What did God promise Abraham?", choices: ["A big boat", "A brand new tent", "A family as many as the stars"], answerIndex: 2),
        QuizQuestion(prompt: "What was Abraham's son's name?", choices: ["Isaac", "Jacob", "Joseph"], answerIndex: 0),
        QuizQuestion(prompt: "What did Abraham do when God made the promise?", choices: ["He laughed and walked away", "He forgot all about it", "He believed and trusted God"], answerIndex: 2),
        QuizQuestion(prompt: "Abraham's family grew to be as many as what?", choices: ["The raindrops", "The stars in the sky", "The seashells"], answerIndex: 1),
        // story: ruth-and-naomi
        QuizQuestion(prompt: "Who did Ruth stay with and take care of?", choices: ["Naomi", "Hannah", "Miriam"], answerIndex: 0),
        QuizQuestion(prompt: "What did Ruth gather in the fields?", choices: ["Flowers", "Grain", "Stones"], answerIndex: 1),
        QuizQuestion(prompt: "Who watched Ruth work and helped her?", choices: ["Eli", "David", "Boaz"], answerIndex: 2),
        QuizQuestion(prompt: "Who became Ruth's husband?", choices: ["Boaz", "Moses", "Jacob"], answerIndex: 0),
        QuizQuestion(prompt: "What filled Naomi's heart when the baby boy came?", choices: ["Worry", "Joy", "Sleepiness"], answerIndex: 1),
        QuizQuestion(prompt: "The story says kindness is like planting what?", choices: ["Tall trees", "Heavy rocks", "Seeds of love"], answerIndex: 2),
        // story: moses-and-the-burning-bush
        QuizQuestion(prompt: "What was Moses' job?", choices: ["Shepherd", "Baker", "Fisherman"], answerIndex: 0),
        QuizQuestion(prompt: "What amazing thing did Moses see?", choices: ["A talking donkey", "A bush on fire that didn't burn up", "A giant rainbow"], answerIndex: 1),
        QuizQuestion(prompt: "Who spoke to Moses from the bush?", choices: ["God", "A king", "Another shepherd"], answerIndex: 0),
        QuizQuestion(prompt: "How did Moses feel at first?", choices: ["Sleepy", "Hungry", "Scared"], answerIndex: 2),
        QuizQuestion(prompt: "What did God promise Moses?", choices: ["\"You'll get new sandals\"", "\"You'll never see fire again\"", "\"I will be with you\""], answerIndex: 2),
        QuizQuestion(prompt: "What did Moses finally say to God?", choices: ["No way", "Yes", "Maybe tomorrow"], answerIndex: 1),
        // story: the-walls-of-water
        QuizQuestion(prompt: "What big water was in front of the people?", choices: ["The Red Sea", "A little pond", "A bathtub"], answerIndex: 0),
        QuizQuestion(prompt: "What did Moses hold up?", choices: ["A lantern", "His staff", "A flag"], answerIndex: 1),
        QuizQuestion(prompt: "What moved the water apart?", choices: ["A big whale", "Lots of shovels", "A strong wind from God"], answerIndex: 2),
        QuizQuestion(prompt: "What did the people walk on through the sea?", choices: ["Dry ground", "A wooden bridge", "Little boats"], answerIndex: 0),
        QuizQuestion(prompt: "What was on both sides of the path?", choices: ["Tall trees", "Walls of water", "Sand castles"], answerIndex: 1),
        QuizQuestion(prompt: "What happened when everyone was safely across?", choices: ["It started to snow", "They built houses", "The water came back together"], answerIndex: 2),
        // story: jacobs-ladder-dream
        QuizQuestion(prompt: "What did Jacob rest his head on?", choices: ["A soft pillow", "A stone", "A pile of leaves"], answerIndex: 1),
        QuizQuestion(prompt: "What did Jacob see in his dream?", choices: ["A ladder reaching to heaven", "A flying boat", "A giant fish"], answerIndex: 0),
        QuizQuestion(prompt: "Who was going up and down the ladder?", choices: ["Sheep", "Shepherds", "Angels"], answerIndex: 2),
        QuizQuestion(prompt: "Who spoke from the top of the ladder?", choices: ["God", "A king", "Jacob's brother"], answerIndex: 0),
        QuizQuestion(prompt: "What did God promise Jacob?", choices: ["\"You will get a new tent\"", "\"You must stay away forever\"", "\"I am with you\""], answerIndex: 2),
        QuizQuestion(prompt: "How did Jacob feel when he woke up?", choices: ["Grumpy", "Full of hope", "Still sleepy"], answerIndex: 1),
        // story: gideons-brave-300
        QuizQuestion(prompt: "How many soldiers did Gideon end up with?", choices: ["300", "3,000", "Just 3"], answerIndex: 0),
        QuizQuestion(prompt: "What did God say about Gideon's army at first?", choices: ["It was too small", "It had too many soldiers", "It needed more horses"], answerIndex: 1),
        QuizQuestion(prompt: "What did each of Gideon's soldiers carry?", choices: ["A torch and a horn", "A sword and a shield", "A drum and a flag"], answerIndex: 0),
        QuizQuestion(prompt: "When did Gideon's men surround the camp?", choices: ["At lunchtime", "In the morning", "In the middle of the night"], answerIndex: 2),
        QuizQuestion(prompt: "What did the enemy soldiers do?", choices: ["They took a nap", "They ran away", "They had a feast"], answerIndex: 1),
        QuizQuestion(prompt: "Where did Gideon's strength really come from?", choices: ["Big muscles", "A huge army", "Trusting God"], answerIndex: 2),
        // story: elijah-and-the-ravens
        QuizQuestion(prompt: "Where did Elijah go to hide?", choices: ["By a stream in the desert", "In a castle", "Up a tall tree"], answerIndex: 0),
        QuizQuestion(prompt: "What birds brought Elijah food?", choices: ["Doves", "Ravens", "Ducks"], answerIndex: 1),
        QuizQuestion(prompt: "What did the ravens bring Elijah?", choices: ["Bread and meat", "Cookies and milk", "Apples and honey"], answerIndex: 0),
        QuizQuestion(prompt: "How often did the ravens come?", choices: ["Once a year", "Only on rainy days", "Every morning and evening"], answerIndex: 2),
        QuizQuestion(prompt: "What did Elijah drink?", choices: ["Juice from a jar", "Fresh water from the stream", "Warm milk"], answerIndex: 1),
        QuizQuestion(prompt: "Who sent the food to take care of Elijah?", choices: ["The king", "A friendly baker", "God"], answerIndex: 2),
        // story: shadrach-meshach-abednego
        QuizQuestion(prompt: "How many friends stood together in this story?", choices: ["Three", "Five", "Ten"], answerIndex: 0),
        QuizQuestion(prompt: "What did the king want everyone to bow to?", choices: ["A big tree", "A golden statue", "His shiny crown"], answerIndex: 1),
        QuizQuestion(prompt: "Who did the three friends say they would bow to?", choices: ["The king", "The statue", "Only God"], answerIndex: 2),
        QuizQuestion(prompt: "How many people did the king see in the furnace?", choices: ["Three", "Four", "Ten"], answerIndex: 1),
        QuizQuestion(prompt: "How did the friends come out of the furnace?", choices: ["Completely safe", "Covered in soot", "Very sleepy"], answerIndex: 0),
        QuizQuestion(prompt: "What did the king say afterward?", choices: ["\"Build a bigger statue\"", "\"Everyone go home\"", "\"Your God is greater than all other gods\""], answerIndex: 2),
        // story: hannahs-prayer
        QuizQuestion(prompt: "What did Hannah want so very much?", choices: ["A baby", "A new house", "A garden"], answerIndex: 0),
        QuizQuestion(prompt: "Where did Hannah go to pray?", choices: ["The seaside", "The temple", "A mountain"], answerIndex: 1),
        QuizQuestion(prompt: "How did Hannah pray?", choices: ["Quietly, with her lips moving", "Shouting very loudly", "Singing with drums"], answerIndex: 0),
        QuizQuestion(prompt: "Who saw Hannah praying?", choices: ["Samuel", "The king", "Eli the priest"], answerIndex: 2),
        QuizQuestion(prompt: "What did Eli tell Hannah?", choices: ["\"Come back tomorrow\"", "\"Please be quiet\"", "\"Go in peace\""], answerIndex: 2),
        QuizQuestion(prompt: "What was Hannah's baby boy named?", choices: ["David", "Samuel", "Joseph"], answerIndex: 1),
        // story: the-garden-of-eden
        QuizQuestion(prompt: "What was the beautiful garden called?", choices: ["Egypt", "Eden", "Jerusalem"], answerIndex: 1),
        QuizQuestion(prompt: "Who did God place in the garden?", choices: ["Adam and Eve", "Noah and his sons", "David and Goliath"], answerIndex: 0),
        QuizQuestion(prompt: "What flowed gently through the garden?", choices: ["A river", "A desert", "A big road"], answerIndex: 0),
        QuizQuestion(prompt: "What were the animals in the garden like?", choices: ["Grumpy", "Sleepy all day", "Friendly and gentle"], answerIndex: 2),
        QuizQuestion(prompt: "What did God do with Adam and Eve every day?", choices: ["Walked and talked with them", "Hid from them", "Sent them letters"], answerIndex: 0),
        QuizQuestion(prompt: "Why did God make the garden for Adam and Eve?", choices: ["He was bored", "Because He loved them", "To sell the fruit"], answerIndex: 1),
        // story: joseph-forgives-brothers
        QuizQuestion(prompt: "Where was Joseph taken when his brothers sold him?", choices: ["Bethlehem", "Jericho", "Egypt"], answerIndex: 2),
        QuizQuestion(prompt: "Why did Joseph's brothers come to Egypt?", choices: ["To go swimming", "To look for food", "To build a wall"], answerIndex: 1),
        QuizQuestion(prompt: "What did Joseph say to his brothers?", choices: ["Go away forever", "I forgive you", "Pay me back"], answerIndex: 1),
        QuizQuestion(prompt: "What did Joseph become in Egypt?", choices: ["A very important man", "A fisherman", "A baker"], answerIndex: 0),
        QuizQuestion(prompt: "What did Joseph give his brothers?", choices: ["Nothing at all", "A long list of chores", "Food and a big hug"], answerIndex: 2),
        QuizQuestion(prompt: "Did the brothers know Joseph at first?", choices: ["No, he had grown up", "Yes, right away", "They never met him"], answerIndex: 0),
        // story: miriams-song
        QuizQuestion(prompt: "What did Miriam pick up?", choices: ["A tambourine", "A trumpet", "A fishing net"], answerIndex: 0),
        QuizQuestion(prompt: "What had the people just crossed?", choices: ["A big mountain", "The Red Sea", "A bridge"], answerIndex: 1),
        QuizQuestion(prompt: "What did Miriam and the women do?", choices: ["Took a nap", "Built a boat", "Sang and danced"], answerIndex: 2),
        QuizQuestion(prompt: "What was Miriam's song about?", choices: ["God saving His people", "Counting sheep", "Baking bread"], answerIndex: 0),
        QuizQuestion(prompt: "Who followed Miriam, singing and dancing?", choices: ["The soldiers", "All the women", "Nobody"], answerIndex: 1),
        QuizQuestion(prompt: "How did the people feel after crossing the sea?", choices: ["Grumpy", "Sleepy and bored", "Free and happy"], answerIndex: 2),
        // story: nehemiah-builds-wall
        QuizQuestion(prompt: "What was broken in Jerusalem?", choices: ["The city walls", "The boats", "The tents"], answerIndex: 0),
        QuizQuestion(prompt: "What did Nehemiah do first when he heard the sad news?", choices: ["He ran away", "He took a nap", "He prayed to God"], answerIndex: 2),
        QuizQuestion(prompt: "Who did Nehemiah ask before going to Jerusalem?", choices: ["The king", "A fisherman", "His sheep"], answerIndex: 0),
        QuizQuestion(prompt: "How did the people rebuild the wall?", choices: ["One person did it alone", "Everyone worked together", "The wall fixed itself"], answerIndex: 1),
        QuizQuestion(prompt: "What happened when some people tried to stop the work?", choices: ["Everyone quit", "They kept working anyway", "They tore the wall down"], answerIndex: 1),
        QuizQuestion(prompt: "What did the people do when the wall was finished?", choices: ["Cried", "Went swimming", "Celebrated and sang"], answerIndex: 2),
        // story: david-shepherd-boy
        QuizQuestion(prompt: "What was David's job?", choices: ["Watching over sheep", "Building boats", "Baking bread"], answerIndex: 0),
        QuizQuestion(prompt: "What did the sheep do when David called them?", choices: ["Ran away", "Came running to him", "Fell asleep"], answerIndex: 1),
        QuizQuestion(prompt: "What did David do if a wild animal came near?", choices: ["Bravely chased it away", "Hid in a cave", "Called the king"], answerIndex: 0),
        QuizQuestion(prompt: "Who did David say was like his shepherd?", choices: ["The king", "His brother", "The Lord"], answerIndex: 2),
        QuizQuestion(prompt: "Where did David's sheep graze?", choices: ["A sandy desert", "A rooftop", "Soft green grass"], answerIndex: 2),
        QuizQuestion(prompt: "How did the sheep feel with David nearby?", choices: ["Scared", "Safe", "Hungry"], answerIndex: 1),
        // story: solomon-asks-wisdom
        QuizQuestion(prompt: "What was Solomon's big new job?", choices: ["Catching fish", "Building boats", "Being the king"], answerIndex: 2),
        QuizQuestion(prompt: "What did Solomon ask God for?", choices: ["Money", "Wisdom", "A pony"], answerIndex: 1),
        QuizQuestion(prompt: "How did God feel about Solomon's prayer?", choices: ["Very pleased", "Angry", "Confused"], answerIndex: 0),
        QuizQuestion(prompt: "Besides wisdom, what did God also give Solomon?", choices: ["A new boat", "Riches and honor", "Nothing"], answerIndex: 1),
        QuizQuestion(prompt: "What did people do when they had hard problems?", choices: ["Hid at home", "Asked the birds", "Came to Solomon for help"], answerIndex: 2),
        QuizQuestion(prompt: "Why did Solomon feel worried at first?", choices: ["He was young and new at being king", "He lost his crown", "He was hungry"], answerIndex: 0),
        // story: jesus-walks-on-water
        QuizQuestion(prompt: "Where were the disciples when the wind blew hard?", choices: ["On a mountain", "In a boat on a lake", "In a garden"], answerIndex: 1),
        QuizQuestion(prompt: "Who came walking on top of the water?", choices: ["A fisherman", "Jesus", "A king"], answerIndex: 1),
        QuizQuestion(prompt: "What did Peter ask Jesus?", choices: ["Can I walk on the water too?", "Can I have a snack?", "Can I row faster?"], answerIndex: 0),
        QuizQuestion(prompt: "Why did Peter start to sink?", choices: ["His shoes were heavy", "The boat tipped over", "He looked at the waves and got scared"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jesus do when Peter cried for help?", choices: ["Reached out and caught him", "Waved goodbye", "Kept on walking"], answerIndex: 0),
        QuizQuestion(prompt: "What happened when Jesus got into the boat?", choices: ["It started raining", "The boat got bigger", "The wind stopped"], answerIndex: 2),
        // story: the-mustard-seed
        QuizQuestion(prompt: "What did Jesus tell a story about?", choices: ["A big whale", "A golden crown", "A tiny seed"], answerIndex: 2),
        QuizQuestion(prompt: "How big is a mustard seed?", choices: ["As big as a house", "The smallest of all seeds", "As big as an apple"], answerIndex: 1),
        QuizQuestion(prompt: "What happened to the tiny seed?", choices: ["It grew into a big plant", "The wind blew it away", "It stayed tiny forever"], answerIndex: 0),
        QuizQuestion(prompt: "Who made nests in the big plant's branches?", choices: ["Fish", "Birds", "Bunnies"], answerIndex: 1),
        QuizQuestion(prompt: "Who planted the seed in his garden?", choices: ["A farmer", "A king", "A fisherman"], answerIndex: 0),
        QuizQuestion(prompt: "What did Jesus want us to learn?", choices: ["Never plant seeds", "Birds are very loud", "Small things can grow big and wonderful"], answerIndex: 2),
        // story: jesus-heals-the-blind-man
        QuizQuestion(prompt: "What could the man by the road not do?", choices: ["Sing", "Walk", "See"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jesus gently put on the man's eyes?", choices: ["Honey", "Mud", "Water drops"], answerIndex: 1),
        QuizQuestion(prompt: "Where did Jesus tell the man to wash?", choices: ["The pool of Siloam", "The Red Sea", "A fountain in Egypt"], answerIndex: 0),
        QuizQuestion(prompt: "What happened after the man washed his eyes?", choices: ["He fell asleep", "Nothing happened", "He could see!"], answerIndex: 2),
        QuizQuestion(prompt: "What did the man see for the very first time?", choices: ["The blue sky", "A snowstorm", "A spaceship"], answerIndex: 0),
        QuizQuestion(prompt: "How did the man feel when he could see?", choices: ["Grumpy", "Happy and grateful", "Bored"], answerIndex: 1),
        // story: the-sower-and-the-seeds
        QuizQuestion(prompt: "What did the farmer throw all around his field?", choices: ["Rocks", "Seeds", "Coins"], answerIndex: 1),
        QuizQuestion(prompt: "What happened to the seeds on the hard path?", choices: ["Birds ate them up", "They grew tall", "They turned blue"], answerIndex: 0),
        QuizQuestion(prompt: "Why did the plants in the rocky ground dry up?", choices: ["They got too much rain", "A goat ate them", "Their roots could not grow deep"], answerIndex: 2),
        QuizQuestion(prompt: "What choked some of the little plants?", choices: ["Thorns and weeds", "Pumpkins", "Rivers"], answerIndex: 0),
        QuizQuestion(prompt: "Which seeds grew strong and made lots of fruit?", choices: ["The ones on the path", "The ones in the thorns", "The ones in good soil"], answerIndex: 2),
        QuizQuestion(prompt: "What is our heart like in this story?", choices: ["The birds", "Good soil", "The hot sun"], answerIndex: 1),
        // story: mary-and-martha
        QuizQuestion(prompt: "Who came to visit Mary and Martha?", choices: ["Moses", "Jesus", "David"], answerIndex: 1),
        QuizQuestion(prompt: "What was Martha busy doing?", choices: ["Cooking and cleaning", "Fishing", "Painting"], answerIndex: 0),
        QuizQuestion(prompt: "Where did Mary sit when Jesus arrived?", choices: ["On the roof", "In the kitchen", "At Jesus's feet"], answerIndex: 2),
        QuizQuestion(prompt: "What did Martha ask Jesus?", choices: ["To sing a song", "To tell Mary to help her", "To wash the dishes"], answerIndex: 1),
        QuizQuestion(prompt: "Who did Jesus say chose what is better?", choices: ["Mary", "Martha", "Peter"], answerIndex: 0),
        QuizQuestion(prompt: "What was Jesus teaching Martha?", choices: ["To run faster", "To cook more food", "To slow down and be peaceful"], answerIndex: 2),
        // story: the-ten-lepers
        QuizQuestion(prompt: "How many sick men called out to Jesus?", choices: ["Ten", "Two", "Seven"], answerIndex: 0),
        QuizQuestion(prompt: "Where did Jesus tell the men to go?", choices: ["To a boat", "To the market", "To the priests"], answerIndex: 2),
        QuizQuestion(prompt: "What happened as the men walked?", choices: ["They got lost", "They were healed", "It started to rain"], answerIndex: 1),
        QuizQuestion(prompt: "How many men came back to say thank you?", choices: ["One", "Nine", "Ten"], answerIndex: 0),
        QuizQuestion(prompt: "What did the thankful man do?", choices: ["He hid behind a tree", "He knelt and thanked Jesus", "He sailed away"], answerIndex: 1),
        QuizQuestion(prompt: "What does this story teach us about prayer?", choices: ["Only ask for toys", "Pray only in the morning", "Remember to say thank you to God"], answerIndex: 2),
        // story: jesus-in-the-garden-of-gethsemane
        QuizQuestion(prompt: "Where did Jesus go to pray that night?", choices: ["A big boat", "A busy market", "A garden called Gethsemane"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jesus do when he felt worried?", choices: ["He ran away", "He prayed to God", "He took a nap"], answerIndex: 1),
        QuizQuestion(prompt: "What were Jesus's friends doing while he prayed?", choices: ["Sleeping", "Singing", "Cooking"], answerIndex: 0),
        QuizQuestion(prompt: "What did Jesus tell God, his Father?", choices: ["A funny joke", "Nothing at all", "Exactly how he felt"], answerIndex: 2),
        QuizQuestion(prompt: "How did Jesus feel after he finished praying?", choices: ["Strong and peaceful", "Still very worried", "Sleepy and grumpy"], answerIndex: 0),
        QuizQuestion(prompt: "What can we do when we feel scared or sad?", choices: ["Keep it a secret forever", "Pray and tell God our feelings", "Stomp our feet"], answerIndex: 1),
        // story: the-empty-tomb
        QuizQuestion(prompt: "Who walked to the tomb early in the morning?", choices: ["Two shepherds", "Two women named Mary", "Two fishermen"], answerIndex: 1),
        QuizQuestion(prompt: "Who came down shining bright from heaven?", choices: ["A king", "A dove", "An angel"], answerIndex: 2),
        QuizQuestion(prompt: "What did the women see at the tomb?", choices: ["The stone was rolled away", "A big feast", "A little boat"], answerIndex: 0),
        QuizQuestion(prompt: "What did the angel tell the women?", choices: ["Be very quiet", "Jesus is alive — he has risen!", "Go back home now"], answerIndex: 1),
        QuizQuestion(prompt: "What did the women do next?", choices: ["They went to sleep", "They hid in the garden", "They ran to tell Jesus's friends"], answerIndex: 2),
        QuizQuestion(prompt: "What does this story teach us?", choices: ["Hope and love always win", "Stones are very heavy", "Mornings are chilly"], answerIndex: 0),
        // story: peter-walks-on-water
        QuizQuestion(prompt: "Where were Jesus's friends that windy night?", choices: ["In a boat on the lake", "On a mountain", "In the temple"], answerIndex: 0),
        QuizQuestion(prompt: "Who did the friends see walking on the water?", choices: ["Moses", "Jesus", "Noah"], answerIndex: 1),
        QuizQuestion(prompt: "Who asked to walk on the water too?", choices: ["John", "Thomas", "Peter"], answerIndex: 2),
        QuizQuestion(prompt: "Why did Peter start to sink?", choices: ["He looked at the waves and got scared", "His sandals were too heavy", "The water got sleepy"], answerIndex: 0),
        QuizQuestion(prompt: "What did Peter call out when he started to sink?", choices: ["Goodbye, everyone!", "Look at me!", "Jesus, help me!"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jesus do when Peter called for help?", choices: ["He paddled away", "He reached out and caught him", "He waited a long time"], answerIndex: 1),
        // story: the-widows-offering
        QuizQuestion(prompt: "Where was Jesus watching people give their money?", choices: ["At the lake", "On a hill", "In the temple"], answerIndex: 2),
        QuizQuestion(prompt: "What did the widow hold in her hand?", choices: ["Two tiny coins", "A big bag of money", "Ten gold rings"], answerIndex: 0),
        QuizQuestion(prompt: "How much of her money did the widow give?", choices: ["None of it", "All of it", "Half of it"], answerIndex: 1),
        QuizQuestion(prompt: "Who did Jesus say gave the most?", choices: ["The rich people", "The soldiers", "The poor widow"], answerIndex: 2),
        QuizQuestion(prompt: "Where does real kindness come from?", choices: ["A big wallet", "A loving heart", "A fancy coat"], answerIndex: 1),
        QuizQuestion(prompt: "What does this story teach us?", choices: ["Small gifts of love matter so much", "Big coins shine brightest", "Only rich people can help"], answerIndex: 0),
        // story: jesus-and-the-woman-at-the-well
        QuizQuestion(prompt: "Where did Jesus stop to rest on the hot day?", choices: ["Under a fig tree", "By a well", "On a boat"], answerIndex: 1),
        QuizQuestion(prompt: "Who came to the well while Jesus rested?", choices: ["A shepherd boy", "A fisherman", "A woman all alone"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jesus ask the woman for?", choices: ["A drink of water", "A loaf of bread", "A warm coat"], answerIndex: 0),
        QuizQuestion(prompt: "What did Jesus offer the woman?", choices: ["Living water that fills the heart", "A new bucket", "A bigger house"], answerIndex: 0),
        QuizQuestion(prompt: "How did Jesus treat the woman?", choices: ["He ignored her", "With kindness and respect", "He asked her to leave"], answerIndex: 1),
        QuizQuestion(prompt: "What did the woman do after talking with Jesus?", choices: ["She hid by the well", "She took a long nap", "She ran to tell the whole town"], answerIndex: 2),
        // story: the-talents
        QuizQuestion(prompt: "What did the rich man give his servants?", choices: ["Money called talents", "New sandals", "Baskets of fruit"], answerIndex: 0),
        QuizQuestion(prompt: "How many talents did the first servant get?", choices: ["Two", "Five", "One"], answerIndex: 1),
        QuizQuestion(prompt: "What did the first two servants do?", choices: ["Threw their talents away", "Lost their talents", "Worked hard so their talents grew"], answerIndex: 2),
        QuizQuestion(prompt: "What did the third servant do with his talent?", choices: ["He gave it away", "He buried it in the ground", "He bought a boat"], answerIndex: 1),
        QuizQuestion(prompt: "What did the master tell the hardworking servants?", choices: ["Well done, good and faithful servant!", "Try again tomorrow", "Where is my dinner?"], answerIndex: 0),
        QuizQuestion(prompt: "What does this story teach us?", choices: ["Never try new things", "Hide everything precious", "Use the gifts God gives us"], answerIndex: 2),
        // story: jesus-washes-the-disciples-feet
        QuizQuestion(prompt: "What were Jesus and his friends doing together?", choices: ["Building a house", "Fishing all night", "Sharing a special meal"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jesus wrap around his waist?", choices: ["A towel", "A blanket", "A rope"], answerIndex: 0),
        QuizQuestion(prompt: "What did Jesus do for his friends?", choices: ["He painted their sandals", "He washed their feet", "He braided their hair"], answerIndex: 1),
        QuizQuestion(prompt: "Which friend said Jesus shouldn't wash his feet?", choices: ["Peter", "Matthew", "John"], answerIndex: 0),
        QuizQuestion(prompt: "Why were people's feet so dusty back then?", choices: ["They jumped in mud for fun", "They never washed at all", "They walked dusty roads in sandals"], answerIndex: 2),
        QuizQuestion(prompt: "What did Jesus want his friends to learn?", choices: ["To eat faster", "To serve and help each other", "To wear bigger sandals"], answerIndex: 1),
        // story: the-light-of-the-world
        QuizQuestion(prompt: "Where was Jesus teaching the big group of people?", choices: ["On a boat", "In the temple", "By the sea"], answerIndex: 1),
        QuizQuestion(prompt: "What did Jesus say he is?", choices: ["The tallest tree", "The fastest runner", "The light of the world"], answerIndex: 2),
        QuizQuestion(prompt: "What happens when we follow Jesus?", choices: ["We never walk in darkness", "We get new sandals", "We grow very tall"], answerIndex: 0),
        QuizQuestion(prompt: "What does light help us do in a dark room?", choices: ["Feel colder", "Hear better", "See where we're going"], answerIndex: 2),
        QuizQuestion(prompt: "What does Jesus want us to be?", choices: ["Quiet as mice", "Little lights too", "Always busy"], answerIndex: 1),
        QuizQuestion(prompt: "How can you shine your light?", choices: ["Being kind and loving", "Shouting very loudly", "Hiding away"], answerIndex: 0),
    ]
}

// MARK: Who Am I? (one riddle per story)

struct WhoAmIRiddle {
    let clues: [String]        // 3 clues, broad → specific
    let choices: [String]      // 3 names
    let answerIndex: Int

    static let bank: [WhoAmIRiddle] = [
        // story: noah-big-boat
        WhoAmIRiddle(clues: ["I listened to God when others did not.", "I worked day after day hammering wood.", "I built a giant boat called an ark!"], choices: ["Moses", "Noah", "David"], answerIndex: 1),
        // story: daniel-and-the-lions
        WhoAmIRiddle(clues: ["I prayed to God every single day.", "Jealous men made a sneaky plan about me.", "An angel shut the lions' mouths for me!"], choices: ["Daniel", "Jonah", "Joseph"], answerIndex: 0),
        // story: jesus-calms-the-storm
        WhoAmIRiddle(clues: ["I was asleep in a rocking boat.", "My friends woke Me when the storm came.", "I said, \"Peace, be still,\" and the waves obeyed!"], choices: ["Peter", "Jonah", "Jesus"], answerIndex: 2),
        // story: the-lost-sheep
        WhoAmIRiddle(clues: ["I'm not a person — I'm small and woolly.", "I wandered away from my ninety-nine friends.", "The shepherd carried me home with joy!"], choices: ["The little donkey", "The lost sheep", "The lost coin"], answerIndex: 1),
        // story: the-birth-of-jesus
        WhoAmIRiddle(clues: ["I traveled a long way to Bethlehem.", "There was no room left for my family to stay.", "I wrapped baby Jesus and laid Him in a manger!"], choices: ["Mary", "The shepherd", "The angel"], answerIndex: 0),
        // story: david-and-goliath
        WhoAmIRiddle(clues: ["I took care of sheep when I was young.", "I was not afraid of a giant.", "I used a sling and one smooth stone!"], choices: ["Goliath", "Daniel", "David"], answerIndex: 2),
        // story: jonah-and-the-big-fish
        WhoAmIRiddle(clues: ["I'm not a person — I live in the deep sea.", "God sent me to keep a runaway safe.", "I carried Jonah three days, then brought him to land!"], choices: ["The big boat", "The big fish", "The friendly dolphin"], answerIndex: 1),
        // story: baby-moses
        WhoAmIRiddle(clues: ["I'm not a person — I was made to float.", "A loving mother placed her baby inside me.", "Pharaoh's daughter found me in the tall reeds!"], choices: ["The basket", "The blanket", "The little boat"], answerIndex: 0),
        // story: the-good-samaritan
        WhoAmIRiddle(clues: ["I was traveling along a road one day.", "I saw a hurt man others walked past.", "I stopped, helped him, and paid for his care!"], choices: ["The robber", "The innkeeper", "The Good Samaritan"], answerIndex: 2),
        // story: creation-story
        WhoAmIRiddle(clues: ["I'm not a person — God made me to shine.", "I come out when the day is done.", "I light the night sky with the stars!"], choices: ["The sun", "The moon", "The sea"], answerIndex: 1),
        // story: joseph-and-his-colorful-coat
        WhoAmIRiddle(clues: ["I'm not a person — I'm something cozy to wear.", "A loving father gave me as a special gift.", "I have many beautiful colors, and Joseph wore me!"], choices: ["A crown", "A colorful coat", "A blanket"], answerIndex: 1),
        // story: the-wise-men
        WhoAmIRiddle(clues: ["I'm not a person — I shine high in the night sky.", "Wise men followed me on a very long journey.", "I led them all the way to Jesus!"], choices: ["The moon", "A candle", "A special star"], answerIndex: 2),
        // story: christmas-the-birth-of-jesus
        WhoAmIRiddle(clues: ["I rested in a stable one quiet holy night.", "I wrapped my baby in soft cloths.", "I laid baby Jesus in a manger!"], choices: ["Mary", "Esther", "Ruth"], answerIndex: 0),
        // story: zacchaeus
        WhoAmIRiddle(clues: ["I wanted very much to see Jesus.", "I was small, so I climbed up high.", "Jesus looked up in my tree and called my name!"], choices: ["Joshua", "Zacchaeus", "Joseph"], answerIndex: 1),
        // story: feeding-the-five-thousand
        WhoAmIRiddle(clues: ["I was in a big crowd listening to Jesus.", "I had a small lunch with me.", "Jesus shared my five loaves and two fish with everyone!"], choices: ["A fisherman", "A king", "The little boy with the lunch"], answerIndex: 2),
        // story: jesus-loves-the-children
        WhoAmIRiddle(clues: ["Families brought their children to see me.", "I said the little children could always come to Me.", "I held the children close and blessed them!"], choices: ["Jesus", "Moses", "Joshua"], answerIndex: 0),
        // story: the-prodigal-son
        WhoAmIRiddle(clues: ["I waited at home for someone I love.", "I saw my son coming while he was still far away.", "I ran to hug him and threw a big celebration!"], choices: ["The big brother", "The loving father", "A shepherd"], answerIndex: 1),
        // story: esthers-courage
        WhoAmIRiddle(clues: ["I lived in a palace as a queen.", "My people were in danger, and I wanted to help.", "I was brave and spoke up at just the right time!"], choices: ["Mary", "Miriam", "Esther"], answerIndex: 2),
        // story: joshua-and-jericho
        WhoAmIRiddle(clues: ["God gave me a very surprising plan.", "My people marched around a city for days.", "When we shouted, God made the walls fall!"], choices: ["Joshua", "Elijah", "David"], answerIndex: 0),
        // story: elijah-and-the-whisper
        WhoAmIRiddle(clues: ["I felt tired, and God gave me rest and care.", "I listened through wind, earthquake, and fire.", "I heard God in a soft, gentle whisper!"], choices: ["Jonah", "Elijah", "Noah"], answerIndex: 1),
        // story: the-boy-samuel
        WhoAmIRiddle(clues: ["I was a boy who lived long ago.", "One night I kept hearing my name being called.", "I said, \"Speak, Lord, I'm listening!\""], choices: ["David", "Samuel", "Eli"], answerIndex: 1),
        // story: abraham-and-the-stars
        WhoAmIRiddle(clues: ["I was an old man with no children.", "One night God showed me the sky full of stars.", "God promised my family would be as many as the stars!"], choices: ["Abraham", "Noah", "Moses"], answerIndex: 0),
        // story: ruth-and-naomi
        WhoAmIRiddle(clues: ["I worked hard in the sunny fields.", "I stayed to take care of my mother-in-law, Naomi.", "I gathered grain, and kind Boaz became my husband!"], choices: ["Naomi", "Hannah", "Ruth"], answerIndex: 2),
        // story: moses-and-the-burning-bush
        WhoAmIRiddle(clues: ["I'm not a person — I grew in the desert.", "Moses saw me glowing bright with fire.", "I never burned up, and God spoke from me!"], choices: ["A tall palm tree", "The burning bush", "A cozy campfire"], answerIndex: 1),
        // story: the-walls-of-water
        WhoAmIRiddle(clues: ["I'm not a person — I'm big, wide, and deep.", "Moses lifted his staff beside me.", "I opened up to make a dry path right through the middle!"], choices: ["The Red Sea", "A little pond", "A rain cloud"], answerIndex: 0),
        // story: jacobs-ladder-dream
        WhoAmIRiddle(clues: ["I was far from home, feeling lonely.", "I slept with my head on a stone.", "I dreamed of a ladder full of angels!"], choices: ["Joseph", "Jacob", "Samuel"], answerIndex: 1),
        // story: gideons-brave-300
        WhoAmIRiddle(clues: ["I led an army that God made smaller and smaller.", "God told me 300 brave men were enough.", "Our torches and horns sent the enemy running!"], choices: ["Gideon", "David", "Joshua"], answerIndex: 0),
        // story: elijah-and-the-ravens
        WhoAmIRiddle(clues: ["We're not people — we're big black birds.", "We flew through the desert sky carrying food.", "We brought Elijah bread and meat every morning and evening!"], choices: ["The doves", "The ravens", "The sparrows"], answerIndex: 1),
        // story: shadrach-meshach-abednego
        WhoAmIRiddle(clues: ["We are three friends who stood together.", "We would only bow to God, never to a statue.", "God kept us safe in the fiery furnace!"], choices: ["Shadrach, Meshach, and Abednego", "Peter, James, and John", "Noah and his sons"], answerIndex: 0),
        // story: hannahs-prayer
        WhoAmIRiddle(clues: ["I wanted a baby very, very much.", "I prayed quietly in the temple, telling God how I felt.", "God gave me a baby boy named Samuel!"], choices: ["Ruth", "Naomi", "Hannah"], answerIndex: 2),
        // story: the-garden-of-eden
        WhoAmIRiddle(clues: ["I'm not a person — I'm the most beautiful place ever made.", "Flowers of every color bloom in me, and a gentle river flows through me.", "Adam and Eve lived in me, and God walked here every day!"], choices: ["The Garden of Eden", "Noah's Ark", "The Red Sea"], answerIndex: 0),
        // story: joseph-forgives-brothers
        WhoAmIRiddle(clues: ["My brothers were jealous and sent me far away from home.", "I worked hard and became an important man in Egypt.", "When my brothers needed food, I forgave them with a big hug!"], choices: ["Moses", "Joseph", "Noah"], answerIndex: 1),
        // story: miriams-song
        WhoAmIRiddle(clues: ["I sang a happy song after God saved my people.", "All the women danced and sang along with me.", "I shook a tambourine with little bells on it!"], choices: ["Miriam", "Esther", "Ruth"], answerIndex: 0),
        // story: nehemiah-builds-wall
        WhoAmIRiddle(clues: ["I heard that my favorite city's walls were broken down.", "I prayed, then asked the king if I could go and fix them.", "Everyone helped me rebuild the wall together!"], choices: ["Noah", "Jonah", "Nehemiah"], answerIndex: 2),
        // story: david-shepherd-boy
        WhoAmIRiddle(clues: ["I take care of woolly friends on a quiet hillside.", "I bravely chase wild animals away to keep my sheep safe.", "I said the Lord is my shepherd!"], choices: ["David", "Joseph", "Peter"], answerIndex: 0),
        // story: solomon-asks-wisdom
        WhoAmIRiddle(clues: ["I became king when I was still young.", "I felt worried about making big decisions for my people.", "I asked God for wisdom, and He made me the wisest king of all!"], choices: ["David", "Solomon", "Moses"], answerIndex: 1),
        // story: jesus-walks-on-water
        WhoAmIRiddle(clues: ["I was in a boat with my friends on a windy night.", "I asked Jesus if I could walk on the water too.", "When I got scared and started to sink, Jesus caught me!"], choices: ["John", "Andrew", "Peter"], answerIndex: 2),
        // story: the-mustard-seed
        WhoAmIRiddle(clues: ["I'm not a person — I'm the smallest of all the seeds.", "A farmer planted me in his garden.", "I grew so big that birds made nests in my branches!"], choices: ["A raindrop", "A mustard seed", "A fig"], answerIndex: 1),
        // story: jesus-heals-the-blind-man
        WhoAmIRiddle(clues: ["I stopped to help a man sitting by the road.", "I made mud and put it gently on his eyes.", "After he washed in the pool, he could see for the first time!"], choices: ["Peter", "Moses", "Jesus"], answerIndex: 2),
        // story: the-sower-and-the-seeds
        WhoAmIRiddle(clues: ["I'm not a person — a farmer threw me all around his field.", "Some of me landed on a path, and some landed in thorns.", "When I landed on good soil, I grew and made fruit!"], choices: ["Raindrops", "Seeds", "Feathers"], answerIndex: 1),
        // story: mary-and-martha
        WhoAmIRiddle(clues: ["I sat very still while my sister rushed around.", "I wanted to hear every word Jesus said.", "Jesus said I chose what is better!"], choices: ["Mary", "Martha", "Ruth"], answerIndex: 0),
        // story: the-ten-lepers
        WhoAmIRiddle(clues: ["I was very sick, and so were nine of my friends.", "Jesus healed me while I was walking.", "I was the only one who ran back to say thank you!"], choices: ["Peter", "The thankful man", "Zacchaeus"], answerIndex: 1),
        // story: jesus-in-the-garden-of-gethsemane
        WhoAmIRiddle(clues: ["I went to a quiet garden one night.", "My heart felt heavy, so I knelt down and prayed.", "Talking to my Father gave me peace and courage!"], choices: ["Peter", "Moses", "Jesus"], answerIndex: 2),
        // story: the-empty-tomb
        WhoAmIRiddle(clues: ["I came down from the sky early one morning.", "I shone so bright by the empty tomb.", "I told the women the best news ever: Jesus is alive!"], choices: ["An angel", "A shepherd", "A fisherman"], answerIndex: 0),
        // story: peter-walks-on-water
        WhoAmIRiddle(clues: ["I was in a boat on a windy night.", "I heard Jesus call and stepped out onto the waves.", "When I started to sink, Jesus caught me!"], choices: ["John", "Peter", "Andrew"], answerIndex: 1),
        // story: the-widows-offering
        WhoAmIRiddle(clues: ["We're not people — we're very, very small.", "We were all the money a kind widow had.", "She dropped us both into the offering box!"], choices: ["Two loaves of bread", "Two shiny crowns", "Two tiny coins"], answerIndex: 2),
        // story: jesus-and-the-woman-at-the-well
        WhoAmIRiddle(clues: ["I'm not a person — I'm a deep hole in the ground.", "People visit me when they are thirsty.", "Jesus rested beside me on a hot, sunny day!"], choices: ["A mountain", "A well", "A boat"], answerIndex: 1),
        // story: the-talents
        WhoAmIRiddle(clues: ["I'm not a person — I'm a special kind of money.", "A scared servant was supposed to help me grow.", "Instead, he buried me in the ground!"], choices: ["A talent", "A pearl", "A seashell"], answerIndex: 0),
        // story: jesus-washes-the-disciples-feet
        WhoAmIRiddle(clues: ["I'm not a person — I'm soft and good at drying.", "Jesus wrapped me around his waist one evening.", "He used me to dry his friends' clean feet!"], choices: ["A towel", "A pillow", "A coat"], answerIndex: 0),
        // story: the-light-of-the-world
        WhoAmIRiddle(clues: ["I taught a big crowd of people in the temple.", "I said whoever follows me will never walk in darkness.", "I am the light of the world!"], choices: ["Moses", "David", "Jesus"], answerIndex: 2),
    ]
}

// MARK: Lumi's True or False (6 items per story x 50 stories)

struct TrueFalseItem {
    let statement: String
    let isTrue: Bool
    /// One gentle line shown after answering.
    let note: String

    static let bank: [TrueFalseItem] = [
        // story: noah-big-boat
        TrueFalseItem(statement: "Noah listened to God and built the ark.", isTrue: true, note: "Yes! Noah trusted God even when it was a very big job."),
        TrueFalseItem(statement: "The animals came onto the ark two by two.", isTrue: true, note: "Big ones, little ones, fuzzy ones, and flappy ones!"),
        TrueFalseItem(statement: "The ark was tiny, with room for just one bunny.", isTrue: false, note: "It was a giant boat with room for Noah's family and many animals."),
        TrueFalseItem(statement: "Noah and his family were safe inside the ark.", isTrue: true, note: "God watched over them through the whole storm."),
        TrueFalseItem(statement: "God put a giant balloon in the sky as His promise.", isTrue: false, note: "It was a rainbow — God's reminder that He keeps His word."),
        TrueFalseItem(statement: "God cares for you just like He cared for Noah.", isTrue: true, note: "God is faithful, loving, and near — always."),
        // story: daniel-and-the-lions
        TrueFalseItem(statement: "Daniel prayed to God every day.", isTrue: true, note: "He loved talking to God, and he never wanted to stop."),
        TrueFalseItem(statement: "Daniel stopped praying when the new law was made.", isTrue: false, note: "Daniel kept right on praying — loving God mattered most."),
        TrueFalseItem(statement: "Some jealous men wanted to get Daniel in trouble.", isTrue: true, note: "They made a sneaky plan, but God took care of Daniel."),
        TrueFalseItem(statement: "God sent an angel to shut the lions' mouths.", isTrue: true, note: "Daniel was safe with God all through the night."),
        TrueFalseItem(statement: "The lions shared a big plate of sandwiches with Daniel.", isTrue: false, note: "Silly! The lions kept their mouths closed all night long."),
        TrueFalseItem(statement: "The king ran to the den in the morning to check on Daniel.", isTrue: true, note: "He was so happy to hear Daniel's voice!"),
        // story: jesus-calms-the-storm
        TrueFalseItem(statement: "Jesus was asleep in the boat when the storm came.", isTrue: true, note: "He was tired after a long day of teaching."),
        TrueFalseItem(statement: "The disciples laughed and danced in the storm.", isTrue: false, note: "They were afraid — so they hurried to wake Jesus."),
        TrueFalseItem(statement: "Jesus said, \"Peace, be still,\" and the storm stopped.", isTrue: true, note: "Even the wind and the waves obey Him!"),
        TrueFalseItem(statement: "The lake became calm when Jesus spoke.", isTrue: true, note: "Jesus is stronger than every storm."),
        TrueFalseItem(statement: "The disciples made the storm stop all by themselves.", isTrue: false, note: "It was Jesus who calmed the storm — they were amazed!"),
        TrueFalseItem(statement: "Jesus can bring peace when our hearts feel worried.", isTrue: true, note: "His peace is gentle, strong, and full of love."),
        // story: the-lost-sheep
        TrueFalseItem(statement: "The shepherd had one hundred sheep.", isTrue: true, note: "And every single one mattered to him."),
        TrueFalseItem(statement: "The shepherd said, \"Oh well,\" and forgot the lost sheep.", isTrue: false, note: "He went looking and searched until he found it!"),
        TrueFalseItem(statement: "The shepherd carried the lost sheep home with joy.", isTrue: true, note: "He lifted it up gently — no scolding at all."),
        TrueFalseItem(statement: "The lost sheep rode home on a bus.", isTrue: false, note: "Silly! The shepherd found it and carried it home himself."),
        TrueFalseItem(statement: "The shepherd told his friends, \"Rejoice with me!\"", isTrue: true, note: "Finding that one little sheep made his heart so happy."),
        TrueFalseItem(statement: "God loves you like the good shepherd loves his sheep.", isTrue: true, note: "No one is too small to matter to God."),
        // story: the-birth-of-jesus
        TrueFalseItem(statement: "Mary and Joseph traveled to Bethlehem.", isTrue: true, note: "It was a long trip, and the town was very crowded."),
        TrueFalseItem(statement: "Baby Jesus was born in a big fancy palace.", isTrue: false, note: "He was born where animals were kept and laid in a manger."),
        TrueFalseItem(statement: "An angel told the shepherds the good news.", isTrue: true, note: "\"Do not be afraid — a Savior has been born!\""),
        TrueFalseItem(statement: "Many angels filled the sky praising God.", isTrue: true, note: "\"Glory to God in the highest, and on earth peace.\""),
        TrueFalseItem(statement: "The shepherds were too sleepy to go see baby Jesus.", isTrue: false, note: "They hurried to Bethlehem right away!"),
        TrueFalseItem(statement: "Jesus is God's greatest gift to the world.", isTrue: true, note: "Full of love, light, and peace."),
        // story: david-and-goliath
        TrueFalseItem(statement: "Everyone at the camp was frightened of Goliath.", isTrue: true, note: "But David remembered God was bigger than the giant."),
        TrueFalseItem(statement: "David wore heavy armor to face Goliath.", isTrue: false, note: "He took just his sling and a few smooth stones."),
        TrueFalseItem(statement: "David said the battle belonged to the Lord.", isTrue: true, note: "He looked at how great God was, not how big the giant was."),
        TrueFalseItem(statement: "It took one hundred stones to win.", isTrue: false, note: "David won — with one little stone and a big trust in God."),
        TrueFalseItem(statement: "David had cared for sheep before he met the giant.", isTrue: true, note: "God had helped him in hard moments before."),
        TrueFalseItem(statement: "David ran away when Goliath laughed at him.", isTrue: false, note: "David went forward with courage — God made him brave."),
        // story: jonah-and-the-big-fish
        TrueFalseItem(statement: "Jonah rode to Nineveh on a camel right away.", isTrue: false, note: "Jonah ran the other way and got on a ship!"),
        TrueFalseItem(statement: "A great storm came while Jonah was on the ship.", isTrue: true, note: "Jonah knew he had been running from God."),
        TrueFalseItem(statement: "God sent a big fish to keep Jonah safe.", isTrue: true, note: "Inside the fish, Jonah prayed and said he was sorry."),
        TrueFalseItem(statement: "Jonah stayed inside the fish for a whole year.", isTrue: false, note: "After three days, the fish brought him to dry land."),
        TrueFalseItem(statement: "Jonah obeyed God and went to Nineveh after all.", isTrue: true, note: "God gave Jonah a second chance."),
        TrueFalseItem(statement: "God is patient and gives second chances.", isTrue: true, note: "Even when we run, God is still near."),
        // story: baby-moses
        TrueFalseItem(statement: "Moses' mother put him in a basket by the river.", isTrue: true, note: "She set it carefully among the tall reeds to keep him safe."),
        TrueFalseItem(statement: "Moses' big sister watched the basket nearby.", isTrue: true, note: "She kept a loving eye on her baby brother."),
        TrueFalseItem(statement: "A talking frog found the basket first.", isTrue: false, note: "Pharaoh's daughter found it and felt compassion for baby Moses."),
        TrueFalseItem(statement: "Pharaoh's daughter chose to protect baby Moses.", isTrue: true, note: "God was already caring for Moses."),
        TrueFalseItem(statement: "Moses' mother never got to see him again.", isTrue: false, note: "Soon his own mother was able to care for him too!"),
        TrueFalseItem(statement: "God watched over baby Moses from the very beginning.", isTrue: true, note: "And He watches over you too."),
        // story: the-good-samaritan
        TrueFalseItem(statement: "Robbers hurt a man traveling on the road.", isTrue: true, note: "He was left by the roadside needing help."),
        TrueFalseItem(statement: "The first people who passed by stopped to help.", isTrue: false, note: "They walked right past — but the Samaritan stopped."),
        TrueFalseItem(statement: "The Samaritan gently cleaned the man's wounds.", isTrue: true, note: "Real kindness notices when someone is hurting."),
        TrueFalseItem(statement: "The Samaritan asked the hurt man to pay him.", isTrue: false, note: "The Samaritan paid for the man's care himself!"),
        TrueFalseItem(statement: "Jesus told this story to show what love looks like.", isTrue: true, note: "Real love stops to help."),
        TrueFalseItem(statement: "The Samaritan rode away and ignored the hurt man.", isTrue: false, note: "He chose mercy and took the man somewhere safe to rest."),
        // story: creation-story
        TrueFalseItem(statement: "God said, \"Let there be light,\" and light began to shine.", isTrue: true, note: "That was the very beginning!"),
        TrueFalseItem(statement: "God made the sun for the day and the moon for the night.", isTrue: true, note: "And He filled the night sky with twinkling stars."),
        TrueFalseItem(statement: "God made fish to fly in the sky.", isTrue: false, note: "Fish swim and birds fly — God gave each one its place."),
        TrueFalseItem(statement: "God made people in His image.", isTrue: true, note: "And He loved them very much."),
        TrueFalseItem(statement: "God looked at the world and said it needed fixing.", isTrue: false, note: "God said it was very good!"),
        TrueFalseItem(statement: "The same God who made the world also made you.", isTrue: true, note: "You are part of God's very good creation."),
        // story: joseph-and-his-colorful-coat
        TrueFalseItem(statement: "Joseph's father gave him a beautiful colorful coat.", isTrue: true, note: "Yes! A special gift from a father who loved him."),
        TrueFalseItem(statement: "Joseph's brothers loved his coat and clapped for him.", isTrue: false, note: "They were jealous — but God still had a good plan."),
        TrueFalseItem(statement: "God stayed with Joseph even in difficult places.", isTrue: true, note: "God never left Joseph, not even for one day."),
        TrueFalseItem(statement: "Joseph never helped his brothers again.", isTrue: false, note: "He did help them! God turned hurt into something good."),
        TrueFalseItem(statement: "Joseph got an important job where he could help many people.", isTrue: true, note: "God lifted Joseph up so he could be a blessing."),
        TrueFalseItem(statement: "God can bring good out of hard situations.", isTrue: true, note: "Even on hard days, God is still working."),
        // story: the-wise-men
        TrueFalseItem(statement: "The wise men saw a special star in the sky.", isTrue: true, note: "That star meant a great King had been born!"),
        TrueFalseItem(statement: "The wise men found Jesus by sailing across the sea.", isTrue: false, note: "They followed the shining star all the way to Jesus."),
        TrueFalseItem(statement: "The wise men bowed down and worshiped Jesus.", isTrue: true, note: "They knew Jesus was worth all their praise."),
        TrueFalseItem(statement: "The wise men gave Jesus precious gifts.", isTrue: true, note: "They brought their very best for the newborn King."),
        TrueFalseItem(statement: "The wise men were grumpy when they found Jesus.", isTrue: false, note: "They were filled with joy — finding Jesus is wonderful!"),
        TrueFalseItem(statement: "The wise men took a long journey to find Jesus.", isTrue: true, note: "Jesus is worth seeking, even from far away."),
        // story: christmas-the-birth-of-jesus
        TrueFalseItem(statement: "Baby Jesus was born in a simple stable.", isTrue: true, note: "There was no room anywhere else, so God chose a stable."),
        TrueFalseItem(statement: "Mary laid baby Jesus in a golden crib.", isTrue: false, note: "She laid Him in a manger, wrapped in soft cloths."),
        TrueFalseItem(statement: "Angels told the shepherds the Savior had been born.", isTrue: true, note: "The best news ever, shining under the night sky!"),
        TrueFalseItem(statement: "The shepherds waited until morning to visit Jesus.", isTrue: false, note: "They hurried right away, with hearts full of joy."),
        TrueFalseItem(statement: "The shepherds found everything just as the angels said.", isTrue: true, note: "God's good news is always true."),
        TrueFalseItem(statement: "The shepherds were watching over their cows.", isTrue: false, note: "They were watching their sheep beneath the stars."),
        // story: zacchaeus
        TrueFalseItem(statement: "Zacchaeus climbed a tree to see Jesus.", isTrue: true, note: "The crowd was big, but Zacchaeus found a way!"),
        TrueFalseItem(statement: "Jesus called Zacchaeus by name.", isTrue: true, note: "Jesus saw him — and Jesus sees you too."),
        TrueFalseItem(statement: "Jesus walked right past the tree without stopping.", isTrue: false, note: "Jesus looked up and called Zacchaeus by name."),
        TrueFalseItem(statement: "Jesus went to Zacchaeus' home.", isTrue: true, note: "Jesus loves to spend time with us."),
        TrueFalseItem(statement: "Zacchaeus was the tallest man in town.", isTrue: false, note: "He was small — that's why he climbed the tree!"),
        TrueFalseItem(statement: "Zacchaeus wanted to make things right and live a better way.", isTrue: true, note: "Jesus' kindness helped his heart change."),
        // story: feeding-the-five-thousand
        TrueFalseItem(statement: "A little boy shared five loaves and two fish.", isTrue: true, note: "His small gift became a big blessing."),
        TrueFalseItem(statement: "The boy had a basket full of birthday cake.", isTrue: false, note: "He had five loaves and two fish — and Jesus made it enough."),
        TrueFalseItem(statement: "Jesus thanked God before sharing the food.", isTrue: true, note: "Saying thank you to God is always a good start."),
        TrueFalseItem(statement: "Everyone had enough to eat, with leftovers too.", isTrue: true, note: "In Jesus' hands, a little became more than enough."),
        TrueFalseItem(statement: "Jesus told the hungry people to go home.", isTrue: false, note: "He fed every single one of them."),
        TrueFalseItem(statement: "The crowd had gathered to hear Jesus.", isTrue: true, note: "They listened all day — and Jesus cared for them."),
        // story: jesus-loves-the-children
        TrueFalseItem(statement: "Families brought children to Jesus so He could bless them.", isTrue: true, note: "And Jesus welcomed every single one."),
        TrueFalseItem(statement: "Jesus was too busy for the children.", isTrue: false, note: "Jesus said, \"Let the little children come to Me.\""),
        TrueFalseItem(statement: "Jesus held the children close and blessed them.", isTrue: true, note: "Children matter deeply to God."),
        TrueFalseItem(statement: "Jesus told the children to come back when they were grown up.", isTrue: false, note: "He welcomed them right then and there."),
        TrueFalseItem(statement: "Some grown-ups tried to send the children away.", isTrue: true, note: "But Jesus did not like that — He wanted them near."),
        TrueFalseItem(statement: "Jesus only blessed the tallest children.", isTrue: false, note: "Jesus welcomed all the children, big and small."),
        // story: the-prodigal-son
        TrueFalseItem(statement: "Jesus told a story about a son who left home.", isTrue: true, note: "A story to show how loving God is."),
        TrueFalseItem(statement: "The father slammed the door when his son came home.", isTrue: false, note: "He ran to him with joy and hugged him!"),
        TrueFalseItem(statement: "The father saw his son while he was still far off.", isTrue: true, note: "He was watching and waiting with love."),
        TrueFalseItem(statement: "The father celebrated when his son came home.", isTrue: true, note: "God's welcome is full of joy."),
        TrueFalseItem(statement: "The son stayed far away forever.", isTrue: false, note: "He came home — and found open arms waiting."),
        TrueFalseItem(statement: "The father made the son sleep outside with the chickens.", isTrue: false, note: "He hugged him, welcomed him home, and celebrated."),
        // story: esthers-courage
        TrueFalseItem(statement: "Esther was a queen.", isTrue: true, note: "God placed her right where she could help."),
        TrueFalseItem(statement: "Esther felt afraid but trusted God.", isTrue: true, note: "Being brave means trusting God, even when you feel scared."),
        TrueFalseItem(statement: "Esther stayed quiet and never spoke up.", isTrue: false, note: "She stepped forward with courage at just the right time."),
        TrueFalseItem(statement: "God used Esther's bravery to protect many people.", isTrue: true, note: "One brave heart can be a big blessing."),
        TrueFalseItem(statement: "Courage means never ever feeling afraid.", isTrue: false, note: "Even brave Esther felt afraid — she trusted God anyway."),
        TrueFalseItem(statement: "Esther's people were in danger, and she helped them.", isTrue: true, note: "God can use your life for good too."),
        // story: joshua-and-jericho
        TrueFalseItem(statement: "God told the people to march around Jericho.", isTrue: true, note: "An unusual plan — but God's way is wise."),
        TrueFalseItem(statement: "Joshua knocked the walls down with a big hammer.", isTrue: false, note: "God made the walls fall when the people shouted."),
        TrueFalseItem(statement: "The people marched for several days.", isTrue: true, note: "They kept trusting God, day after day."),
        TrueFalseItem(statement: "At the end, the people whispered very quietly.", isTrue: false, note: "They shouted — and God made the walls fall!"),
        TrueFalseItem(statement: "God caused the walls of Jericho to fall.", isTrue: true, note: "God is faithful, and His plans are good."),
        TrueFalseItem(statement: "Joshua decided God's plan was too strange to follow.", isTrue: false, note: "Joshua obeyed, even when the plan was surprising."),
        // story: elijah-and-the-whisper
        TrueFalseItem(statement: "Elijah felt tired and discouraged.", isTrue: true, note: "Even God's helpers have hard days — and God cares."),
        TrueFalseItem(statement: "God gave Elijah rest and gentle care.", isTrue: true, note: "God is kind when we are weary."),
        TrueFalseItem(statement: "God was in the strong wind.", isTrue: false, note: "God was not in the wind — He came in a gentle whisper."),
        TrueFalseItem(statement: "After the wind came an earthquake, and later a fire.", isTrue: true, note: "But God was not in those either."),
        TrueFalseItem(statement: "God shouted at Elijah very loudly.", isTrue: false, note: "God spoke in a soft, gentle whisper."),
        TrueFalseItem(statement: "God met Elijah in a soft gentle whisper.", isTrue: true, note: "God is near in peaceful, quiet moments too."),
        // story: the-boy-samuel
        TrueFalseItem(statement: "Samuel heard his name being called at night.", isTrue: true, note: "Yes! God was calling Samuel by name."),
        TrueFalseItem(statement: "Eli was the one calling Samuel's name.", isTrue: false, note: "It was God calling! Kind Eli helped Samuel understand."),
        TrueFalseItem(statement: "Samuel said, \"Speak, Lord, for Your servant is listening.\"", isTrue: true, note: "Yes! Samuel listened with a willing heart."),
        TrueFalseItem(statement: "Samuel hid under his blanket and never answered.", isTrue: false, note: "No — Samuel got up every time and answered the call."),
        TrueFalseItem(statement: "God knew Samuel's name.", isTrue: true, note: "He did! And God knows your name too."),
        TrueFalseItem(statement: "Samuel listened with a willing heart.", isTrue: true, note: "Yes! Listening for God is something you can do too."),
        // story: abraham-and-the-stars
        TrueFalseItem(statement: "Abraham saw more stars than he could count.", isTrue: true, note: "So many stars! God used them to show His big promise."),
        TrueFalseItem(statement: "God promised Abraham a family as many as the stars.", isTrue: true, note: "Yes! God's promise was as big as the night sky."),
        TrueFalseItem(statement: "Abraham's son was named Isaac.", isTrue: true, note: "Yes! Isaac was the start of Abraham's growing family."),
        TrueFalseItem(statement: "God told Abraham to count all the fish in the sea.", isTrue: false, note: "It was the stars! God showed Abraham the night sky."),
        TrueFalseItem(statement: "Abraham said the promise was silly and walked away.", isTrue: false, note: "No — Abraham believed God, even when it seemed impossible."),
        TrueFalseItem(statement: "God kept His promise to Abraham.", isTrue: true, note: "He did! God always keeps His promises."),
        // story: ruth-and-naomi
        TrueFalseItem(statement: "Ruth stayed to take care of Naomi.", isTrue: true, note: "Yes! Ruth's loving heart never left Naomi's side."),
        TrueFalseItem(statement: "Ruth gathered grain so Naomi had food to eat.", isTrue: true, note: "Yes! Ruth worked hard in the hot sun for someone she loved."),
        TrueFalseItem(statement: "Ruth left Naomi to find an easier life.", isTrue: false, note: "No — Ruth stayed! Her kindness changed everything."),
        TrueFalseItem(statement: "Boaz saw how kind Ruth was to Naomi.", isTrue: true, note: "He did, and his heart was touched by her kindness."),
        TrueFalseItem(statement: "Ruth gathered ice cream cones in the fields.", isTrue: false, note: "Silly! Ruth gathered grain to make food for Naomi."),
        TrueFalseItem(statement: "Ruth and Boaz had a baby boy.", isTrue: true, note: "Yes! And Naomi's heart filled right up with joy."),
        // story: moses-and-the-burning-bush
        TrueFalseItem(statement: "Moses saw a bush on fire that did not burn up.", isTrue: true, note: "Yes! It was an amazing sight, glowing but never burning."),
        TrueFalseItem(statement: "Moses felt scared at first.", isTrue: true, note: "He did — and that's okay. Being brave starts with feeling scared."),
        TrueFalseItem(statement: "God told Moses, \"I will be with you.\"", isTrue: true, note: "Yes! Moses didn't have to be brave all by himself."),
        TrueFalseItem(statement: "The bush burned all the way up into smoke.", isTrue: false, note: "No — the wonderful bush kept glowing and never burned up!"),
        TrueFalseItem(statement: "Moses said no and went back to his sheep.", isTrue: false, note: "No — Moses took a deep breath and said yes!"),
        TrueFalseItem(statement: "Moses was brave because God was with him.", isTrue: true, note: "Yes! God gives us courage when we feel afraid."),
        // story: the-walls-of-water
        TrueFalseItem(statement: "The Red Sea opened up into a dry path.", isTrue: true, note: "Yes! God made a way right through the middle of the sea."),
        TrueFalseItem(statement: "The people crossed the sea in little boats.", isTrue: false, note: "No boats needed — they walked on dry ground!"),
        TrueFalseItem(statement: "There were walls of water on both sides of the path.", isTrue: true, note: "Yes! It was like walking through a tunnel made of water."),
        TrueFalseItem(statement: "Moses said, \"Don't be afraid. Watch what God will do.\"", isTrue: true, note: "Yes! Moses trusted God even when everyone felt scared."),
        TrueFalseItem(statement: "The people swam all the way across the sea.", isTrue: false, note: "No swimming! God gave them a dry path to walk on."),
        TrueFalseItem(statement: "God kept the people safe, just like He promised.", isTrue: true, note: "He did! God can make a way even when things seem impossible."),
        // story: jacobs-ladder-dream
        TrueFalseItem(statement: "Jacob used a stone for a pillow.", isTrue: true, note: "Yes! He had no pillow, so he rested his head on a stone."),
        TrueFalseItem(statement: "Jacob dreamed of a ladder reaching up to heaven.", isTrue: true, note: "Yes! The most beautiful dream, stretching from earth to heaven."),
        TrueFalseItem(statement: "Angels were going up and down the ladder.", isTrue: true, note: "Yes! Beautiful, glowing angels all around the ladder."),
        TrueFalseItem(statement: "Jacob dreamed about a big slide full of monkeys.", isTrue: false, note: "Silly! It was a ladder with angels going up and down."),
        TrueFalseItem(statement: "God told Jacob, \"I am with you.\"", isTrue: true, note: "Yes! And God promised to bring Jacob safely home again."),
        TrueFalseItem(statement: "Jacob woke up more scared than before.", isTrue: false, note: "No — Jacob woke up full of hope! He knew God was with him."),
        // story: gideons-brave-300
        TrueFalseItem(statement: "Gideon ended up with just 300 soldiers.", isTrue: true, note: "Yes! A little army with a great big trust in God."),
        TrueFalseItem(statement: "Each soldier carried a torch and a horn.", isTrue: true, note: "Yes! That was God's clever plan."),
        TrueFalseItem(statement: "Gideon's soldiers rode in on giant elephants.", isTrue: false, note: "No elephants! They quietly surrounded the camp on foot."),
        TrueFalseItem(statement: "The enemy soldiers ran away.", isTrue: true, note: "They did! The horns and torches made them think a huge army had come."),
        TrueFalseItem(statement: "God said Gideon needed many more soldiers.", isTrue: false, note: "It was the opposite — God said the army was too big!"),
        TrueFalseItem(statement: "Gideon won because he trusted God's plan.", isTrue: true, note: "Yes! Strength comes from trusting God, not from being big."),
        // story: elijah-and-the-ravens
        TrueFalseItem(statement: "Ravens brought Elijah bread and meat.", isTrue: true, note: "Yes! Big black birds carried food right to him."),
        TrueFalseItem(statement: "The ravens came every morning and every evening.", isTrue: true, note: "Yes! Morning after morning, evening after evening."),
        TrueFalseItem(statement: "Elijah drank fresh water from the stream.", isTrue: true, note: "Yes! God took care of everything Elijah needed."),
        TrueFalseItem(statement: "Elijah ordered pizza in the desert.", isTrue: false, note: "Silly! There were no stores — God sent ravens with food instead."),
        TrueFalseItem(statement: "Elijah worried every day about where food would come from.", isTrue: false, note: "No — Elijah trusted God completely, and God always provided."),
        TrueFalseItem(statement: "God knew exactly what Elijah needed.", isTrue: true, note: "He did! And God knows what you need too."),
        // story: shadrach-meshach-abednego
        TrueFalseItem(statement: "The three friends said they would only bow to God.", isTrue: true, note: "Yes! They stood together and stayed true to God."),
        TrueFalseItem(statement: "The friends bowed down to the golden statue.", isTrue: false, note: "No — they said, \"We can only bow to God.\""),
        TrueFalseItem(statement: "The king saw four people walking in the furnace.", isTrue: true, note: "Yes! The fourth figure shone like an angel."),
        TrueFalseItem(statement: "The friends came out without even a smell of smoke.", isTrue: true, note: "Yes! Not a single hair was burned. God kept them safe."),
        TrueFalseItem(statement: "The friends held hands and stood together.", isTrue: true, note: "Yes! Brave friends are even braver together."),
        TrueFalseItem(statement: "The king said his statue was greater than God.", isTrue: false, note: "No — the king said, \"Your God is greater than all other gods!\""),
        // story: hannahs-prayer
        TrueFalseItem(statement: "Hannah told God exactly how she felt.", isTrue: true, note: "Yes! You can tell God everything in your heart, just like Hannah."),
        TrueFalseItem(statement: "Hannah prayed quietly with her lips moving.", isTrue: true, note: "Yes! God hears even the quietest prayers."),
        TrueFalseItem(statement: "Hannah asked the king to give her a baby.", isTrue: false, note: "No — Hannah asked God! She trusted Him to hear her."),
        TrueFalseItem(statement: "God gave Hannah a baby boy named Samuel.", isTrue: true, note: "Yes! God heard Hannah's prayer and answered it."),
        TrueFalseItem(statement: "Eli told Hannah, \"Go in peace.\"", isTrue: true, note: "Yes! Eli believed God would answer her prayer."),
        TrueFalseItem(statement: "Hannah forgot her promise to God.", isTrue: false, note: "No — Hannah kept her promise, and Samuel grew up to love God."),
        // story: the-garden-of-eden
        TrueFalseItem(statement: "The Garden of Eden was full of flowers and fruit trees.", isTrue: true, note: "Yes! God filled it with every beautiful color and delicious fruit."),
        TrueFalseItem(statement: "The animals in the garden were scary and mean.", isTrue: false, note: "Not at all — the animals were friendly and gentle."),
        TrueFalseItem(statement: "God walked in the garden with Adam and Eve like best friends.", isTrue: true, note: "Yes! God loved spending time with them every day."),
        TrueFalseItem(statement: "Adam and Eve were sad and afraid in the garden.", isTrue: false, note: "No — there was no sadness or fear, only love and happiness."),
        TrueFalseItem(statement: "A gentle river flowed through the garden.", isTrue: true, note: "Yes! A gentle river flowed right through Eden."),
        TrueFalseItem(statement: "God made the garden because He loved Adam and Eve.", isTrue: true, note: "Yes — and He made you because He loves you too!"),
        // story: joseph-forgives-brothers
        TrueFalseItem(statement: "Joseph's brothers sold him to travelers who took him to Egypt.", isTrue: true, note: "Yes — but God stayed with Joseph the whole time."),
        TrueFalseItem(statement: "Joseph yelled at his brothers and sent them away.", isTrue: false, note: "No — Joseph said \"I forgive you\" and hugged them."),
        TrueFalseItem(statement: "Joseph cried happy tears when he forgave his brothers.", isTrue: true, note: "Yes — forgiving made his heart light and free."),
        TrueFalseItem(statement: "Joseph's brothers came to Egypt to buy new sandals.", isTrue: false, note: "Silly! They came looking for food, and Joseph shared with them."),
        TrueFalseItem(statement: "Joseph invited his brothers to live with him in Egypt.", isTrue: true, note: "Yes! His kindness felt like a warm blanket around their hearts."),
        TrueFalseItem(statement: "Joseph never stopped believing in God, even far from home.", isTrue: true, note: "Yes — and God helped him become an important man."),
        // story: miriams-song
        TrueFalseItem(statement: "Miriam played a tambourine with little bells on it.", isTrue: true, note: "Yes! She shook it while she sang to the Lord."),
        TrueFalseItem(statement: "Miriam's song said God is wonderful and mighty.", isTrue: true, note: "Yes — her song thanked God for saving His people."),
        TrueFalseItem(statement: "Miriam told everyone to be quiet and sit still.", isTrue: false, note: "Just the opposite — she led everyone in singing and dancing!"),
        TrueFalseItem(statement: "Even the children danced and clapped their hands.", isTrue: true, note: "Yes! Everyone celebrated together with joyful music."),
        TrueFalseItem(statement: "The people were sad after crossing the Red Sea.", isTrue: false, note: "No — they were free at last, and their hearts were full of joy!"),
        TrueFalseItem(statement: "Miriam's song helped everyone remember God kept His promise.", isTrue: true, note: "Yes — God brought His people safely to freedom."),
        // story: nehemiah-builds-wall
        TrueFalseItem(statement: "Nehemiah prayed to God for help before he began.", isTrue: true, note: "Yes — God gave him courage and a plan."),
        TrueFalseItem(statement: "Nehemiah built the whole wall all by himself.", isTrue: false, note: "No — everyone worked together, side by side, as a team."),
        TrueFalseItem(statement: "Some people carried stones and some mixed cement.", isTrue: true, note: "Yes! Everyone had a job, and together they were strong."),
        TrueFalseItem(statement: "Nehemiah gave up when the work got hard.", isTrue: false, note: "Never! He and the people kept working, day after day."),
        TrueFalseItem(statement: "The wall was finished after many weeks of hard work.", isTrue: true, note: "Yes — the city was safe again, and everyone sang for joy!"),
        TrueFalseItem(statement: "Working together helped the people do something amazing.", isTrue: true, note: "Yes — with God's help and teamwork, big problems can be solved."),
        // story: david-shepherd-boy
        TrueFalseItem(statement: "David watched his sheep on a quiet hillside.", isTrue: true, note: "Yes — the sheep grazed on soft green grass all around him."),
        TrueFalseItem(statement: "David's sheep were afraid of him.", isTrue: false, note: "No — the sheep trusted David and came running when he called."),
        TrueFalseItem(statement: "David said the Lord is my shepherd.", isTrue: true, note: "Yes — God watches over us just like David watched his sheep."),
        TrueFalseItem(statement: "David slept all night and forgot about his sheep.", isTrue: false, note: "No — David watched over them at night to keep them safe."),
        TrueFalseItem(statement: "David's voice was loud and scary.", isTrue: false, note: "No — David's voice was kind and warm, and the sheep loved it."),
        TrueFalseItem(statement: "God watches over you like a loving shepherd.", isTrue: true, note: "Yes — you are His precious little lamb, safe and loved."),
        // story: solomon-asks-wisdom
        TrueFalseItem(statement: "Solomon asked God for wisdom instead of money.", isTrue: true, note: "Yes — he wanted to make good decisions for his people."),
        TrueFalseItem(statement: "Solomon asked God for a hundred camels.", isTrue: false, note: "Silly! Solomon asked for wisdom — the very best thing to ask for."),
        TrueFalseItem(statement: "God made Solomon the wisest king in all the land.", isTrue: true, note: "Yes — God was so pleased that He gave even more than Solomon asked."),
        TrueFalseItem(statement: "God was upset that Solomon asked for wisdom.", isTrue: false, note: "No — God was very pleased with Solomon's unselfish prayer."),
        TrueFalseItem(statement: "Solomon wanted to understand right from wrong.", isTrue: true, note: "Yes — what we ask for in prayer shows what we really care about."),
        TrueFalseItem(statement: "People came to Solomon when they had hard problems.", isTrue: true, note: "Yes — his wise answers helped them."),
        // story: jesus-walks-on-water
        TrueFalseItem(statement: "Jesus walked on top of the water.", isTrue: true, note: "Yes — His friends could hardly believe their eyes!"),
        TrueFalseItem(statement: "Peter stepped out of the boat and walked toward Jesus.", isTrue: true, note: "Yes — Peter walked on the water when he kept looking at Jesus."),
        TrueFalseItem(statement: "Jesus swam over to the boat.", isTrue: false, note: "No — Jesus walked right on top of the water!"),
        TrueFalseItem(statement: "Jesus caught Peter right away when he started to sink.", isTrue: true, note: "Yes — the moment Peter called for help, Jesus reached out."),
        TrueFalseItem(statement: "The wind blew even harder when Jesus got in the boat.", isTrue: false, note: "No — the wind stopped and the water became calm and peaceful."),
        TrueFalseItem(statement: "The friends said Jesus really is God's Son.", isTrue: true, note: "Yes — they were amazed, and Jesus was right there with them."),
        // story: the-mustard-seed
        TrueFalseItem(statement: "The mustard seed is so tiny you can barely see it.", isTrue: true, note: "Yes — it is the smallest seed of all!"),
        TrueFalseItem(statement: "The tiny mustard seed grew into a big, big plant.", isTrue: true, note: "Yes — from something so small came something big and strong."),
        TrueFalseItem(statement: "The birds were too scared to go near the plant.", isTrue: false, note: "No — the birds came and made cozy nests in its branches!"),
        TrueFalseItem(statement: "Jesus said little hopes can grow into big blessings.", isTrue: true, note: "Yes — good things can come from small beginnings."),
        TrueFalseItem(statement: "The farmer threw the seed into the sea.", isTrue: false, note: "Silly! He planted it in his garden, where it could grow."),
        TrueFalseItem(statement: "Jesus said the mustard seed stayed small forever.", isTrue: false, note: "No — it grew and grew and grew into a big plant!"),
        // story: jesus-heals-the-blind-man
        TrueFalseItem(statement: "The man had been blind since he was born.", isTrue: true, note: "Yes — he had never seen the sky or the faces he loved."),
        TrueFalseItem(statement: "Jesus walked right past the man without stopping.", isTrue: false, note: "No — Jesus stopped and looked at him with so much love."),
        TrueFalseItem(statement: "The man trusted Jesus and walked to the pool.", isTrue: true, note: "Yes — he trusted Jesus even before he could see."),
        TrueFalseItem(statement: "When the man washed his eyes, he could see.", isTrue: true, note: "Yes! He saw the blue sky for the very first time."),
        TrueFalseItem(statement: "The man was sad that he could see.", isTrue: false, note: "No — tears of joy ran down his face, and he thanked Jesus."),
        TrueFalseItem(statement: "The man ran back to find Jesus, happy and grateful.", isTrue: true, note: "Yes — he shouted, \"I can see!\" Jesus loves to help us."),
        // story: the-sower-and-the-seeds
        TrueFalseItem(statement: "The farmer threw seeds all around his field.", isTrue: true, note: "Yes — he scattered seeds everywhere as he walked."),
        TrueFalseItem(statement: "Birds ate the seeds that fell on the hard path.", isTrue: true, note: "Yes — those seeds never had a chance to grow."),
        TrueFalseItem(statement: "The seeds in the good soil grew strong and made fruit.", isTrue: true, note: "Yes — deep roots, water, and sunshine helped them grow tall!"),
        TrueFalseItem(statement: "The thorny weeds helped the little plants grow tall.", isTrue: false, note: "No — the thorns crowded them out so they could not grow."),
        TrueFalseItem(statement: "Every single seed grew, no matter where it landed.", isTrue: false, note: "No — only the seeds in good soil grew big and strong."),
        TrueFalseItem(statement: "When we open our hearts to God, good things grow inside us.", isTrue: true, note: "Yes — hope, love, and joy grow in a heart like good soil."),
        // story: mary-and-martha
        TrueFalseItem(statement: "Jesus came to visit Mary and Martha's house.", isTrue: true, note: "Yes! The two sisters had a very special visitor that day."),
        TrueFalseItem(statement: "Martha was busy cooking and cleaning.", isTrue: true, note: "Yes — Martha rushed around making everything perfect."),
        TrueFalseItem(statement: "Mary helped Martha scrub all the pots and pans.", isTrue: false, note: "No — Mary sat at Jesus's feet so she could listen to him."),
        TrueFalseItem(statement: "Mary sat at Jesus's feet and listened to him.", isTrue: true, note: "Yes — Mary was calm and peaceful, just enjoying being near Jesus."),
        TrueFalseItem(statement: "Jesus told Mary to hurry up and get busy.", isTrue: false, note: "No — Jesus said Mary had chosen what is better."),
        TrueFalseItem(statement: "Jesus said being still with him matters most of all.", isTrue: true, note: "Yes — sometimes the best thing is to slow down and be peaceful."),
        // story: the-ten-lepers
        TrueFalseItem(statement: "Only two sick men asked Jesus for help.", isTrue: false, note: "No — there were ten men, and Jesus healed every one!"),
        TrueFalseItem(statement: "Jesus told the men to climb a tall mountain.", isTrue: false, note: "No — he told them to go show themselves to the priests."),
        TrueFalseItem(statement: "All ten men were healed as they walked.", isTrue: true, note: "Yes! Every single one got better on the way."),
        TrueFalseItem(statement: "All ten men came back to say thank you.", isTrue: false, note: "Only one came back — and his thank-you made Jesus so glad."),
        TrueFalseItem(statement: "One man knelt down and thanked Jesus over and over.", isTrue: true, note: "Yes — he came back with a heart full of joy and thanks."),
        TrueFalseItem(statement: "Saying thank you to God makes our hearts feel full.", isTrue: true, note: "Yes — prayer is also about telling God thank you for our blessings."),
        // story: jesus-in-the-garden-of-gethsemane
        TrueFalseItem(statement: "Jesus prayed in a quiet garden with olive trees.", isTrue: true, note: "Yes — the garden was called Gethsemane."),
        TrueFalseItem(statement: "Jesus told God exactly how he was feeling.", isTrue: true, note: "Yes — Jesus was honest with his Father about feeling sad and worried."),
        TrueFalseItem(statement: "Jesus's friends stayed wide awake the whole night.", isTrue: false, note: "No — they fell asleep, and Jesus gently woke them up."),
        TrueFalseItem(statement: "Praying helped Jesus feel strong and peaceful.", isTrue: true, note: "Yes — after praying, Jesus felt courage and peace."),
        TrueFalseItem(statement: "Jesus kept all his feelings a secret from God.", isTrue: false, note: "No — Jesus told God everything, and we can too."),
        TrueFalseItem(statement: "We can pray just like Jesus when we feel worried.", isTrue: true, note: "Yes — tell God your feelings, and he will comfort you."),
        // story: the-empty-tomb
        TrueFalseItem(statement: "The big stone was rolled away from the tomb.", isTrue: true, note: "Yes — the women saw the tomb wide open!"),
        TrueFalseItem(statement: "Jesus was still resting inside the tomb.", isTrue: false, note: "No — the tomb was empty because Jesus is alive!"),
        TrueFalseItem(statement: "The angel told the women not to be afraid.", isTrue: true, note: "Yes — the angel had wonderful good news for them."),
        TrueFalseItem(statement: "The women kept the good news a secret.", isTrue: false, note: "No — they ran with joy to tell Jesus's friends!"),
        TrueFalseItem(statement: "The women were full of joy at the happy news.", isTrue: true, note: "Yes — they shouted, \"He's alive! He's alive!\""),
        TrueFalseItem(statement: "The angel arrived quietly riding a little donkey.", isTrue: false, note: "No — the ground shook, and the angel shone bright from heaven!"),
        // story: peter-walks-on-water
        TrueFalseItem(statement: "Peter stepped out of the boat onto the water.", isTrue: true, note: "Yes — that was a very brave step!"),
        TrueFalseItem(statement: "Peter really walked on the water toward Jesus.", isTrue: true, note: "Yes — one step, then another, closer and closer to Jesus."),
        TrueFalseItem(statement: "Peter sank because the boat had a hole in it.", isTrue: false, note: "No — Peter started to sink when fear filled his heart."),
        TrueFalseItem(statement: "Jesus caught Peter right away when he called for help.", isTrue: true, note: "Yes — Jesus reached out and held him safe."),
        TrueFalseItem(statement: "Jesus floated by on a big yellow raft.", isTrue: false, note: "No — Jesus was walking right on top of the water!"),
        TrueFalseItem(statement: "Courage means trusting Jesus even when we feel scared.", isTrue: true, note: "Yes — brave hearts believe in Jesus and call for help when they need it."),
        // story: the-widows-offering
        TrueFalseItem(statement: "The widow put two tiny coins in the offering box.", isTrue: true, note: "Yes — she gave both of her little coins."),
        TrueFalseItem(statement: "The widow kept one coin for herself.", isTrue: false, note: "No — she gave both coins, everything she had!"),
        TrueFalseItem(statement: "Jesus said the widow gave more than all the others.", isTrue: true, note: "Yes — because she gave from her heart."),
        TrueFalseItem(statement: "The rich people gave money they didn't really need.", isTrue: true, note: "Yes — they gave from what they had left over."),
        TrueFalseItem(statement: "You have to be rich to be kind.", isTrue: false, note: "No — kindness comes from the heart, not from money."),
        TrueFalseItem(statement: "Even small acts of kindness make the world beautiful.", isTrue: true, note: "Yes — a smile, a hug, or sharing matters so much."),
        // story: jesus-and-the-woman-at-the-well
        TrueFalseItem(statement: "Jesus rested by a well on a hot, sunny day.", isTrue: true, note: "Yes — he was tired and thirsty from walking."),
        TrueFalseItem(statement: "The woman came to the well with lots of friends.", isTrue: false, note: "No — she came all alone, but Jesus saw her and loved her."),
        TrueFalseItem(statement: "Jesus asked the woman for a bowl of soup.", isTrue: false, note: "No — he asked her for a drink of water from the well."),
        TrueFalseItem(statement: "Jesus turned away and would not talk to her.", isTrue: false, note: "No — Jesus spoke to her like she really mattered."),
        TrueFalseItem(statement: "Jesus knew all about the woman and loved her anyway.", isTrue: true, note: "Yes — he loved her just as she was, and he loves you that way too."),
        TrueFalseItem(statement: "The woman ran to tell the whole town about Jesus.", isTrue: true, note: "Yes — she said, \"Come meet someone who knows me and loves me anyway!\""),
        // story: the-talents
        TrueFalseItem(statement: "The rich man gave his servants talents to care for.", isTrue: true, note: "Yes — five, two, and one, before his long journey."),
        TrueFalseItem(statement: "The first servant's five talents grew into ten.", isTrue: true, note: "Yes — he worked hard and made smart choices."),
        TrueFalseItem(statement: "The third servant made his talent grow the most.", isTrue: false, note: "No — he was scared and buried it in the ground."),
        TrueFalseItem(statement: "The third servant hid his talent because he was scared.", isTrue: true, note: "Yes — he worried about making a mistake, so he never tried."),
        TrueFalseItem(statement: "The master was happy the talent stayed buried.", isTrue: false, note: "No — the master was sad that the gift was never used."),
        TrueFalseItem(statement: "God gives each of us special gifts to use and grow.", isTrue: true, note: "Yes — don't be scared to use your gifts!"),
        // story: jesus-washes-the-disciples-feet
        TrueFalseItem(statement: "Jesus washed his friends' feet at the special meal.", isTrue: true, note: "Yes — he knelt down and washed them gently, one by one."),
        TrueFalseItem(statement: "Jesus asked a servant to wash everyone's feet.", isTrue: false, note: "No — Jesus did the humble job himself, with love."),
        TrueFalseItem(statement: "Peter was surprised that Jesus washed his feet.", isTrue: true, note: "Yes — Peter thought the teacher shouldn't do a servant's job."),
        TrueFalseItem(statement: "Jesus dried each friend's feet with a towel.", isTrue: true, note: "Yes — he was gentle and careful with every one."),
        TrueFalseItem(statement: "Jesus said only kings should help other people.", isTrue: false, note: "No — Jesus said we should all serve each other."),
        TrueFalseItem(statement: "Kindness means helping, even with small humble jobs.", isTrue: true, note: "Yes — small, gentle acts of kindness are precious."),
        // story: the-light-of-the-world
        TrueFalseItem(statement: "Jesus said, \"I am the light of the world.\"", isTrue: true, note: "Yes — he said it while teaching in the temple."),
        TrueFalseItem(statement: "Jesus said his followers would walk in darkness.", isTrue: false, note: "No — whoever follows Jesus will never walk in darkness."),
        TrueFalseItem(statement: "Light helps us see and feel safe.", isTrue: true, note: "Yes — when the light comes on, everything changes!"),
        TrueFalseItem(statement: "Jesus wants us to hide our kindness away.", isTrue: false, note: "No — he wants our love to shine bright for everyone."),
        TrueFalseItem(statement: "Every kind thing you do shines like a little light.", isTrue: true, note: "Yes — your smiles and helping hands light up the world."),
        TrueFalseItem(statement: "Jesus said only grown-ups can shine his light.", isTrue: false, note: "No — everyone can shine, even the littlest light!"),
    ]
}

// MARK: Story Scramble (one per story)

struct ScrambleStory {
    let title: String
    let steps: [String]   // 4 steps in correct order

    static let bank: [ScrambleStory] = [
        // story: noah-big-boat
        ScrambleStory(title: "Noah and the Big Boat", steps: ["God told Noah to build a big ark", "The animals came aboard two by two", "Rain fell and the ark floated safely", "God put a rainbow in the sky"]),
        // story: daniel-and-the-lions
        ScrambleStory(title: "Daniel and the Lions", steps: ["Jealous men made a law about praying", "Daniel kept praying to God anyway", "Daniel spent the night with the lions", "God's angel shut the lions' mouths"]),
        // story: jesus-calms-the-storm
        ScrambleStory(title: "Jesus Calms the Storm", steps: ["Jesus and His friends sailed across the lake", "A big storm rocked the boat", "Jesus said, \"Peace, be still\"", "The wind and waves became calm"]),
        // story: the-lost-sheep
        ScrambleStory(title: "The Lost Sheep", steps: ["The shepherd had one hundred sheep", "One little sheep wandered away", "The shepherd searched until he found it", "He carried it home with joy"]),
        // story: the-birth-of-jesus
        ScrambleStory(title: "The Birth of Jesus", steps: ["Mary and Joseph traveled to Bethlehem", "Baby Jesus was born and laid in a manger", "An angel told shepherds the good news", "The shepherds hurried to see baby Jesus"]),
        // story: david-and-goliath
        ScrambleStory(title: "David and Goliath", steps: ["Goliath shouted and everyone was afraid", "Young David trusted God and stepped forward", "One smooth stone flew straight and true", "The giant fell and God gave victory"]),
        // story: jonah-and-the-big-fish
        ScrambleStory(title: "Jonah and the Big Fish", steps: ["Jonah ran away on a ship", "A big fish swallowed Jonah", "Jonah prayed and said he was sorry", "Jonah obeyed and went to Nineveh"]),
        // story: baby-moses
        ScrambleStory(title: "Baby Moses", steps: ["His mother placed Moses in a basket", "His big sister watched nearby", "Pharaoh's daughter found the basket", "Moses' own mother helped care for him"]),
        // story: the-good-samaritan
        ScrambleStory(title: "The Good Samaritan", steps: ["Robbers hurt a traveler on the road", "Some people passed by without helping", "A kind Samaritan stopped to help him", "He took the man somewhere safe to rest"]),
        // story: creation-story
        ScrambleStory(title: "Creation Story", steps: ["God said, \"Let there be light\"", "God made the sky, land, and seas", "God made the sun, moon, and stars", "God made people and said it was very good"]),
        // story: joseph-and-his-colorful-coat
        ScrambleStory(title: "Joseph and His Colorful Coat", steps: ["Joseph's father gives him a colorful coat", "Joseph is taken far away from home", "God stays with Joseph and gives him wisdom", "Joseph gets an important job and helps his brothers"]),
        // story: the-wise-men
        ScrambleStory(title: "The Wise Men", steps: ["Wise men see a special star in the sky", "They begin a long journey to find the King", "The star leads them to Jesus", "They bow, worship, and give precious gifts"]),
        // story: christmas-the-birth-of-jesus
        ScrambleStory(title: "Christmas: The Birth of Jesus", steps: ["Mary and Joseph rest in a simple stable", "Baby Jesus is born and laid in a manger", "Angels tell the shepherds the wonderful news", "The shepherds hurry to see baby Jesus"]),
        // story: zacchaeus
        ScrambleStory(title: "Zacchaeus", steps: ["Zacchaeus wants to see Jesus over the crowd", "He climbs up into a tree", "Jesus looks up and calls his name", "Jesus visits his home and his heart changes"]),
        // story: feeding-the-five-thousand
        ScrambleStory(title: "Feeding the Five Thousand", steps: ["A big crowd gets hungry listening to Jesus", "A boy shares five loaves and two fish", "Jesus thanks God and shares the food", "Everyone eats, and there are leftovers too"]),
        // story: jesus-loves-the-children
        ScrambleStory(title: "Jesus Loves the Children", steps: ["Families bring their children to Jesus", "Some grown-ups try to send them away", "Jesus says the children can come to Him", "Jesus holds the children close and blesses them"]),
        // story: the-prodigal-son
        ScrambleStory(title: "The Prodigal Son", steps: ["A son leaves home and goes far away", "He decides to come back home", "His father sees him and runs to him", "The father hugs him and celebrates"]),
        // story: esthers-courage
        ScrambleStory(title: "Esther’s Courage", steps: ["Esther becomes a queen", "She learns her people are in danger", "She bravely steps forward and speaks up", "God uses her courage to protect many people"]),
        // story: joshua-and-jericho
        ScrambleStory(title: "Joshua and Jericho", steps: ["God gives Joshua an unusual plan", "The people march around Jericho for days", "At the right moment, everyone shouts", "God makes the walls of Jericho fall"]),
        // story: elijah-and-the-whisper
        ScrambleStory(title: "Elijah and the Whisper", steps: ["Elijah feels tired, and God gives him rest", "A strong wind and an earthquake pass by", "A fire passes, but God is not in it", "God speaks to Elijah in a gentle whisper"]),
        // story: the-boy-samuel
        ScrambleStory(title: "The Boy Samuel", steps: ["Samuel lies down to sleep at night", "He hears his name and runs to Eli", "Eli understands that God is calling Samuel", "Samuel says, \"Speak, Lord, I'm listening\""]),
        // story: abraham-and-the-stars
        ScrambleStory(title: "Abraham and the Stars", steps: ["Abraham feels sad with no children", "God shows him the sky full of stars", "God promises a family as many as stars", "Baby Isaac is born and the family grows"]),
        // story: ruth-and-naomi
        ScrambleStory(title: "Ruth and Naomi", steps: ["Ruth stays with sad, lonely Naomi", "Ruth gathers grain in the hot fields", "Kind Boaz helps Ruth and marries her", "A baby boy fills Naomi with joy"]),
        // story: moses-and-the-burning-bush
        ScrambleStory(title: "Moses and the Burning Bush", steps: ["Moses watches his sheep in the desert", "He sees a bush on fire, not burning", "God says, \"I will be with you\"", "Moses says yes and helps God's people"]),
        // story: the-walls-of-water
        ScrambleStory(title: "The Walls of Water", steps: ["The people reach the big Red Sea", "Moses holds his staff up high", "The wind opens a dry path through", "Everyone crosses and the water comes back"]),
        // story: jacobs-ladder-dream
        ScrambleStory(title: "Jacob's Ladder Dream", steps: ["Jacob lies down with a stone pillow", "He dreams of a ladder up to heaven", "God promises, \"I am with you\"", "Jacob wakes up full of hope"]),
        // story: gideons-brave-300
        ScrambleStory(title: "Gideon's Brave 300", steps: ["God says Gideon's army is too big", "Only 300 brave soldiers stay", "They blow horns and raise torches at night", "The surprised enemy runs away"]),
        // story: elijah-and-the-ravens
        ScrambleStory(title: "Elijah and the Ravens", steps: ["Elijah hides by a stream in the desert", "He wonders where food will come from", "Ravens fly in with bread and meat", "God cares for Elijah every single day"]),
        // story: shadrach-meshach-abednego
        ScrambleStory(title: "Shadrach, Meshach, and Abednego", steps: ["The king tells everyone to bow to a statue", "Three friends say they only bow to God", "They are put into the hot furnace", "They walk out safe, with God beside them"]),
        // story: hannahs-prayer
        ScrambleStory(title: "Hannah's Prayer", steps: ["Hannah feels sad and wants a baby", "She prays quietly in the temple", "Eli says, \"Go in peace\"", "God gives Hannah baby Samuel"]),
        // story: the-garden-of-eden
        ScrambleStory(title: "The Garden of Eden", steps: ["God made a beautiful garden called Eden", "God placed Adam and Eve in the garden", "Adam and Eve played with the gentle animals", "God walked and talked with them every day"]),
        // story: joseph-forgives-brothers
        ScrambleStory(title: "Joseph Forgives His Brothers", steps: ["Joseph's brothers sold him to travelers", "Joseph became an important man in Egypt", "His brothers came to Egypt looking for food", "Joseph forgave his brothers and hugged them"]),
        // story: miriams-song
        ScrambleStory(title: "Miriam's Song", steps: ["The people crossed the Red Sea safely", "Miriam picked up her tambourine", "She sang and danced to thank God", "All the women joined the joyful song"]),
        // story: nehemiah-builds-wall
        ScrambleStory(title: "Nehemiah Builds the Wall", steps: ["Nehemiah heard the walls were broken", "He prayed and asked the king to go", "Everyone worked together on the wall", "The wall was finished and everyone celebrated"]),
        // story: david-shepherd-boy
        ScrambleStory(title: "David the Shepherd Boy", steps: ["David watched his sheep eat green grass", "He called the scared sheep back to him", "At night David kept the sheep safe", "David said the Lord is my shepherd"]),
        // story: solomon-asks-wisdom
        ScrambleStory(title: "Solomon Asks for Wisdom", steps: ["Young Solomon became the new king", "He prayed and asked God for wisdom", "God gladly gave him wisdom and more", "People came to wise Solomon for help"]),
        // story: jesus-walks-on-water
        ScrambleStory(title: "Jesus Walks on Water", steps: ["The wind blew hard on the lake", "Jesus came walking on the water", "Peter walked, got scared, and began sinking", "Jesus caught Peter and the wind stopped"]),
        // story: the-mustard-seed
        ScrambleStory(title: "The Mustard Seed", steps: ["Jesus told a story about a tiny seed", "A farmer planted the seed in his garden", "The seed grew into a big plant", "Birds made nests in its branches"]),
        // story: jesus-heals-the-blind-man
        ScrambleStory(title: "Jesus Heals the Blind Man", steps: ["A blind man called out to Jesus", "Jesus put mud on the man's eyes", "The man washed in the pool of Siloam", "He could see and thanked Jesus"]),
        // story: the-sower-and-the-seeds
        ScrambleStory(title: "The Sower and the Seeds", steps: ["A farmer threw seeds around his field", "Birds ate the seeds on the hard path", "Thorns choked some of the little plants", "Seeds in good soil grew strong and tall"]),
        // story: mary-and-martha
        ScrambleStory(title: "Mary and Martha", steps: ["Jesus comes to visit the two sisters", "Martha gets very busy cooking and cleaning", "Mary sits quietly at Jesus's feet", "Jesus says Mary chose what is better"]),
        // story: the-ten-lepers
        ScrambleStory(title: "The Ten Lepers", steps: ["Ten sick men call out to Jesus", "Jesus sends them to the priests", "All ten are healed as they walk", "One man comes back to say thank you"]),
        // story: jesus-in-the-garden-of-gethsemane
        ScrambleStory(title: "Jesus in the Garden of Gethsemane", steps: ["Jesus goes to the quiet garden at night", "He kneels and tells God his feelings", "He finds his sleepy friends and prays again", "Jesus feels God's peace and courage"]),
        // story: the-empty-tomb
        ScrambleStory(title: "The Empty Tomb", steps: ["Two women walk to the tomb early", "A shining angel comes down from heaven", "The stone is rolled away — Jesus is risen", "The women run to share the happy news"]),
        // story: peter-walks-on-water
        ScrambleStory(title: "Peter Walks on Water", steps: ["The friends see Jesus walking on the water", "Peter steps out of the boat", "Peter sees the waves and starts to sink", "Jesus reaches out and catches Peter"]),
        // story: the-widows-offering
        ScrambleStory(title: "The Widow's Offering", steps: ["Rich people put big coins in the box", "A poor widow comes with two tiny coins", "She gives both coins — everything she has", "Jesus says she gave the most of all"]),
        // story: jesus-and-the-woman-at-the-well
        ScrambleStory(title: "Jesus and the Woman at the Well", steps: ["Jesus rests by a well on a hot day", "A woman comes alone to get water", "Jesus offers her living water and love", "She runs to tell the whole town"]),
        // story: the-talents
        ScrambleStory(title: "The Talents", steps: ["The master gives his servants talents to keep", "Two servants work hard and their talents grow", "One servant buries his talent in the ground", "The master comes home and sees what happened"]),
        // story: jesus-washes-the-disciples-feet
        ScrambleStory(title: "Jesus Washes the Disciples' Feet", steps: ["Jesus and his friends share a special meal", "Jesus wraps a towel around his waist", "He gently washes each friend's feet", "Jesus tells them to serve each other too"]),
        // story: the-light-of-the-world
        ScrambleStory(title: "The Light of the World", steps: ["Jesus teaches many people in the temple", "He says he is the light of the world", "His light shows us the safe way", "Jesus asks us to shine our light too"]),
    ]
}

// MARK: Verse Builder (one short, chip-friendly verse per story)

struct BuilderVerse {
    let storyTitle: String
    let text: String        // 4-12 words, no surrounding quotes
    let reference: String

    static let bank: [BuilderVerse] = [
        // story: noah-big-boat
        BuilderVerse(storyTitle: "Noah and the Big Boat", text: "I have set my rainbow in the clouds", reference: "Genesis 9:13"),
        // story: daniel-and-the-lions
        BuilderVerse(storyTitle: "Daniel and the Lions", text: "My God sent his angel and shut the lions' mouths", reference: "Daniel 6:22"),
        // story: jesus-calms-the-storm
        BuilderVerse(storyTitle: "Jesus Calms the Storm", text: "Jesus said to the wind and waves, Peace, be still", reference: "Mark 4:39"),
        // story: the-lost-sheep
        BuilderVerse(storyTitle: "The Lost Sheep", text: "There will be more rejoicing in heaven over one who repents", reference: "Luke 15:7"),
        // story: the-birth-of-jesus
        BuilderVerse(storyTitle: "The Birth of Jesus", text: "Unto you is born this day a Savior", reference: "Luke 2:11"),
        // story: david-and-goliath
        BuilderVerse(storyTitle: "David and Goliath", text: "The Lord who rescued me will rescue me again", reference: "1 Samuel 17:37"),
        // story: jonah-and-the-big-fish
        BuilderVerse(storyTitle: "Jonah and the Big Fish", text: "I called to the Lord and he answered me", reference: "Jonah 2:2"),
        // story: baby-moses
        BuilderVerse(storyTitle: "Baby Moses", text: "I drew him out of the water", reference: "Exodus 2:10"),
        // story: the-good-samaritan
        BuilderVerse(storyTitle: "The Good Samaritan", text: "Love your neighbor as yourself", reference: "Luke 10:27"),
        // story: creation-story
        BuilderVerse(storyTitle: "Creation Story", text: "In the beginning God created the heavens and the earth", reference: "Genesis 1:1"),
        // story: joseph-and-his-colorful-coat
        BuilderVerse(storyTitle: "Joseph and His Colorful Coat", text: "You intended to harm me, but God intended it for good", reference: "Genesis 50:20"),
        // story: the-wise-men
        BuilderVerse(storyTitle: "The Wise Men", text: "We saw his star when it rose", reference: "Matthew 2:2"),
        // story: christmas-the-birth-of-jesus
        BuilderVerse(storyTitle: "Christmas: The Birth of Jesus", text: "Glory to God in the highest, and on earth peace", reference: "Luke 2:14"),
        // story: zacchaeus
        BuilderVerse(storyTitle: "Zacchaeus", text: "The Son of Man came to seek and to save the lost", reference: "Luke 19:10"),
        // story: feeding-the-five-thousand
        BuilderVerse(storyTitle: "Feeding the Five Thousand", text: "They all ate and were satisfied", reference: "Matthew 14:20"),
        // story: jesus-loves-the-children
        BuilderVerse(storyTitle: "Jesus Loves the Children", text: "Let the little children come to me", reference: "Mark 10:14"),
        // story: the-prodigal-son
        BuilderVerse(storyTitle: "The Prodigal Son", text: "He was lost and is found", reference: "Luke 15:24"),
        // story: esthers-courage
        BuilderVerse(storyTitle: "Esther’s Courage", text: "For such a time as this", reference: "Esther 4:14"),
        // story: joshua-and-jericho
        BuilderVerse(storyTitle: "Joshua and Jericho", text: "Be strong and courageous. Do not be afraid", reference: "Joshua 1:9"),
        // story: elijah-and-the-whisper
        BuilderVerse(storyTitle: "Elijah and the Whisper", text: "The Lord was not in the wind, but in a gentle whisper", reference: "1 Kings 19:11-12"),
        // story: the-boy-samuel
        BuilderVerse(storyTitle: "The Boy Samuel", text: "Speak, Lord, for your servant is listening", reference: "1 Samuel 3:9"),
        // story: abraham-and-the-stars
        BuilderVerse(storyTitle: "Abraham and the Stars", text: "The Lord is faithful to all his promises", reference: "Psalm 145:13"),
        // story: ruth-and-naomi
        BuilderVerse(storyTitle: "Ruth and Naomi", text: "Where you go I will go", reference: "Ruth 1:16"),
        // story: moses-and-the-burning-bush
        BuilderVerse(storyTitle: "Moses and the Burning Bush", text: "Be strong and brave, for God is with you", reference: "Joshua 1:9"),
        // story: the-walls-of-water
        BuilderVerse(storyTitle: "The Walls of Water", text: "Nothing is impossible with God", reference: "Luke 1:37"),
        // story: jacobs-ladder-dream
        BuilderVerse(storyTitle: "Jacob's Ladder Dream", text: "I am with you and will watch over you wherever you go", reference: "Genesis 28:15"),
        // story: gideons-brave-300
        BuilderVerse(storyTitle: "Gideon's Brave 300", text: "With the three hundred men I will save you", reference: "Judges 7:7"),
        // story: elijah-and-the-ravens
        BuilderVerse(storyTitle: "Elijah and the Ravens", text: "My God will meet all your needs", reference: "Philippians 4:19"),
        // story: shadrach-meshach-abednego
        BuilderVerse(storyTitle: "Shadrach, Meshach, and Abednego", text: "The God we serve is able to deliver us", reference: "Daniel 3:17"),
        // story: hannahs-prayer
        BuilderVerse(storyTitle: "Hannah's Prayer", text: "The Lord has granted me what I asked of him", reference: "1 Samuel 1:27"),
        // story: the-garden-of-eden
        BuilderVerse(storyTitle: "The Garden of Eden", text: "We love because he first loved us", reference: "1 John 4:19"),
        // story: joseph-forgives-brothers
        BuilderVerse(storyTitle: "Joseph Forgives His Brothers", text: "Do not be afraid", reference: "Genesis 50:19"),
        // story: miriams-song
        BuilderVerse(storyTitle: "Miriam's Song", text: "Sing to the Lord, for he is highly exalted", reference: "Exodus 15:21"),
        // story: nehemiah-builds-wall
        BuilderVerse(storyTitle: "Nehemiah Builds the Wall", text: "The God of heaven will give us success", reference: "Nehemiah 2:20"),
        // story: david-shepherd-boy
        BuilderVerse(storyTitle: "David the Shepherd Boy", text: "The Lord is my shepherd, I shall not want", reference: "Psalm 23:1"),
        // story: solomon-asks-wisdom
        BuilderVerse(storyTitle: "Solomon Asks for Wisdom", text: "Give your servant a discerning heart", reference: "1 Kings 3:9"),
        // story: jesus-walks-on-water
        BuilderVerse(storyTitle: "Jesus Walks on Water", text: "Take courage! It is I. Don't be afraid", reference: "Matthew 14:27"),
        // story: the-mustard-seed
        BuilderVerse(storyTitle: "The Mustard Seed", text: "If you have faith as small as a mustard seed", reference: "Matthew 17:20"),
        // story: jesus-heals-the-blind-man
        BuilderVerse(storyTitle: "Jesus Heals the Blind Man", text: "I was blind but now I see", reference: "John 9:25"),
        // story: the-sower-and-the-seeds
        BuilderVerse(storyTitle: "The Sower and the Seeds", text: "Still other seed fell on good soil, where it produced a crop", reference: "Matthew 13:8"),
        // story: mary-and-martha
        BuilderVerse(storyTitle: "Mary and Martha", text: "Mary has chosen what is better", reference: "Luke 10:42"),
        // story: the-ten-lepers
        BuilderVerse(storyTitle: "The Ten Lepers", text: "Were not all ten cleansed? Where are the other nine?", reference: "Luke 17:17"),
        // story: jesus-in-the-garden-of-gethsemane
        BuilderVerse(storyTitle: "Jesus in the Garden of Gethsemane", text: "Not my will, but yours be done", reference: "Luke 22:42"),
        // story: the-empty-tomb
        BuilderVerse(storyTitle: "The Empty Tomb", text: "He is not here; he has risen!", reference: "Luke 24:6"),
        // story: peter-walks-on-water
        BuilderVerse(storyTitle: "Peter Walks on Water", text: "Tell me to come to you on the water", reference: "Matthew 14:28"),
        // story: the-widows-offering
        BuilderVerse(storyTitle: "The Widow's Offering", text: "This poor widow has put in more than all the others", reference: "Luke 21:3"),
        // story: jesus-and-the-woman-at-the-well
        BuilderVerse(storyTitle: "Jesus and the Woman at the Well", text: "Whoever drinks the water I give them will never thirst", reference: "John 4:14"),
        // story: the-talents
        BuilderVerse(storyTitle: "The Talents", text: "Well done, good and faithful servant!", reference: "Matthew 25:21"),
        // story: jesus-washes-the-disciples-feet
        BuilderVerse(storyTitle: "Jesus Washes the Disciples' Feet", text: "I have set you an example", reference: "John 13:15"),
        // story: the-light-of-the-world
        BuilderVerse(storyTitle: "The Light of the World", text: "I am the light of the world", reference: "John 8:12"),
    ]
}

// MARK: - Game deck (no-repeat rotation)

/// Deals bank indices like a shuffled deck of cards: every item comes up
/// once before any item repeats, and the round just played is never dealt
/// again in the round that follows — so consecutive games always differ.
/// Decks persist in UserDefaults across launches, one per game key.
enum GameDeck {
    /// Draws `count` indices for the game `key` over a bank of `bankSize`.
    static func draw(_ count: Int, from bankSize: Int, key: String) -> [Int] {
        guard bankSize > 0 else { return [] }
        let take = min(count, bankSize)
        let defaults = UserDefaults.standard
        let deckKey = "gameDeck.\(key)"
        let sizeKey = "gameDeck.\(key).bankSize"
        let lastKey = "gameDeck.\(key).lastDraw"

        var deck = (defaults.array(forKey: deckKey) as? [Int]) ?? []
        // A content update changes the bank — start a fresh deck
        if defaults.integer(forKey: sizeKey) != bankSize {
            deck = []
            defaults.removeObject(forKey: lastKey)
        }
        deck.removeAll { $0 >= bankSize }

        if deck.count < take {
            // Reshuffle: leftovers stay on top, the just-played round is
            // pushed to the back so the next deal can't repeat it.
            let leftovers = deck
            let last = Set((defaults.array(forKey: lastKey) as? [Int]) ?? [])
            var fresh = Array(0..<bankSize).shuffled()
                .filter { !leftovers.contains($0) }
            if bankSize > take * 2 {
                fresh = fresh.filter { !last.contains($0) } + fresh.filter { last.contains($0) }
            }
            deck = leftovers + fresh
        }

        let drawn = Array(deck.prefix(take))
        deck.removeFirst(take)
        defaults.set(deck, forKey: deckKey)
        defaults.set(bankSize, forKey: sizeKey)
        defaults.set(drawn, forKey: lastKey)
        return drawn
    }
}
