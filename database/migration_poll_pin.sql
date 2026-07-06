-- Poll tables for Staff Chat
CREATE TABLE IF NOT EXISTS `chat_polls` (
  `id` int NOT NULL AUTO_INCREMENT,
  `conversation_id` int NOT NULL,
  `question` varchar(500) NOT NULL,
  `created_by_role` varchar(50) NOT NULL,
  `created_by_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_closed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `conversation_id` (`conversation_id`),
  CONSTRAINT `chat_polls_conv_fk` FOREIGN KEY (`conversation_id`) REFERENCES `chat_conversations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `chat_poll_options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `poll_id` int NOT NULL,
  `option_text` varchar(300) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `poll_id` (`poll_id`),
  CONSTRAINT `chat_poll_options_fk` FOREIGN KEY (`poll_id`) REFERENCES `chat_polls` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `chat_poll_votes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `poll_id` int NOT NULL,
  `option_id` int NOT NULL,
  `voter_role` varchar(50) NOT NULL,
  `voter_id` int NOT NULL,
  `voted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_poll_vote` (`poll_id`, `voter_role`, `voter_id`),
  CONSTRAINT `chat_poll_votes_fk1` FOREIGN KEY (`poll_id`) REFERENCES `chat_polls` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chat_poll_votes_fk2` FOREIGN KEY (`option_id`) REFERENCES `chat_poll_options` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Pinned messages
CREATE TABLE IF NOT EXISTS `chat_pinned_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `conversation_id` int NOT NULL,
  `message_id` bigint NOT NULL,
  `pinned_by_role` varchar(50) NOT NULL,
  `pinned_by_id` int NOT NULL,
  `pinned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pin` (`conversation_id`, `message_id`),
  CONSTRAINT `chat_pin_conv_fk` FOREIGN KEY (`conversation_id`) REFERENCES `chat_conversations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chat_pin_msg_fk` FOREIGN KEY (`message_id`) REFERENCES `chat_messages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
