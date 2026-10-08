CREATE TABLE `batches` (
	`id` bigint unsigned AUTO_INCREMENT NOT NULL,
	`device_id` bigint unsigned NOT NULL,
	`label` varchar(120),
	`started_at` datetime NOT NULL,
	`matured_at` datetime,
	`harvested_at` datetime,
	`status` varchar(16) NOT NULL DEFAULT 'fermenting',
	`created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT `batches_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `commands` (
	`id` char(36) NOT NULL,
	`device_id` bigint unsigned NOT NULL,
	`action` varchar(24) NOT NULL,
	`payload` json,
	`status` varchar(16) NOT NULL DEFAULT 'pending',
	`created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`sent_at` datetime,
	`acked_at` datetime,
	`expires_at` datetime NOT NULL,
	CONSTRAINT `commands_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `devices` (
	`id` bigint unsigned AUTO_INCREMENT NOT NULL,
	`name` varchar(120) NOT NULL,
	`device_key` char(64) NOT NULL,
	`location` varchar(160),
	`firmware_version` varchar(32),
	`last_seen_at` datetime,
	`is_online` tinyint NOT NULL DEFAULT 0,
	`created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `devices_id` PRIMARY KEY(`id`),
	CONSTRAINT `devices_device_key_unique` UNIQUE(`device_key`)
);
--> statement-breakpoint
CREATE TABLE `events` (
	`id` bigint unsigned AUTO_INCREMENT NOT NULL,
	`device_id` bigint unsigned NOT NULL,
	`type` varchar(32) NOT NULL,
	`severity` varchar(16) NOT NULL DEFAULT 'info',
	`message` text NOT NULL,
	`payload` json,
	`is_read` tinyint NOT NULL DEFAULT 0,
	`created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT `events_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `latest_state` (
	`device_id` bigint unsigned NOT NULL,
	`temp_c` decimal(5,2),
	`nh3_ppm` decimal(8,3),
	`temp_ok` tinyint NOT NULL DEFAULT 1,
	`heater_on` tinyint NOT NULL DEFAULT 0,
	`valve_open` tinyint NOT NULL DEFAULT 0,
	`mode` varchar(16) NOT NULL DEFAULT 'AUTO',
	`status` varchar(24) NOT NULL DEFAULT 'idle',
	`updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `latest_state_device_id` PRIMARY KEY(`device_id`)
);
--> statement-breakpoint
CREATE TABLE `sensor_readings` (
	`id` bigint unsigned AUTO_INCREMENT NOT NULL,
	`device_id` bigint unsigned NOT NULL,
	`temp_c` decimal(5,2),
	`nh3_ppm` decimal(8,3),
	`heater_on` tinyint NOT NULL DEFAULT 0,
	`valve_open` tinyint NOT NULL DEFAULT 0,
	`status` varchar(24) NOT NULL DEFAULT 'idle',
	`sampled_at` datetime NOT NULL,
	CONSTRAINT `sensor_readings_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `settings` (
	`id` bigint unsigned AUTO_INCREMENT NOT NULL,
	`device_id` bigint unsigned NOT NULL,
	`history_interval_min` int NOT NULL DEFAULT 15,
	`ingest_interval_sec` int NOT NULL DEFAULT 10,
	`temp_min_c` decimal(5,2) NOT NULL DEFAULT 30,
	`temp_max_c` decimal(5,2) NOT NULL DEFAULT 45,
	`temp_hysteresis_c` decimal(5,2) NOT NULL DEFAULT 2,
	`nh3_mature_ppm` decimal(8,3) NOT NULL DEFAULT 25,
	`mature_hold_min` int NOT NULL DEFAULT 30,
	`heater_auto` tinyint NOT NULL DEFAULT 1,
	`heater_max_on_min` int NOT NULL DEFAULT 60,
	`valve_max_open_min` int NOT NULL DEFAULT 10,
	`command_ttl_sec` int NOT NULL DEFAULT 60,
	`raw_retention_days` int NOT NULL DEFAULT 30,
	`updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `settings_id` PRIMARY KEY(`id`),
	CONSTRAINT `settings_device_id_unique` UNIQUE(`device_id`)
);
--> statement-breakpoint
CREATE TABLE `telemetry_raw` (
	`id` bigint unsigned AUTO_INCREMENT NOT NULL,
	`device_id` bigint unsigned NOT NULL,
	`temp_c` decimal(5,2),
	`nh3_ppm` decimal(8,3),
	`heater_on` tinyint NOT NULL DEFAULT 0,
	`valve_open` tinyint NOT NULL DEFAULT 0,
	`recorded_at` datetime NOT NULL,
	CONSTRAINT `telemetry_raw_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `batches` ADD CONSTRAINT `batches_device_id_devices_id_fk` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `commands` ADD CONSTRAINT `commands_device_id_devices_id_fk` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `events` ADD CONSTRAINT `events_device_id_devices_id_fk` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `latest_state` ADD CONSTRAINT `latest_state_device_id_devices_id_fk` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `sensor_readings` ADD CONSTRAINT `sensor_readings_device_id_devices_id_fk` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `settings` ADD CONSTRAINT `settings_device_id_devices_id_fk` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `telemetry_raw` ADD CONSTRAINT `telemetry_raw_device_id_devices_id_fk` FOREIGN KEY (`device_id`) REFERENCES `devices`(`id`) ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `idx_batch_device` ON `batches` (`device_id`,`status`);--> statement-breakpoint
CREATE INDEX `idx_cmd_device_status` ON `commands` (`device_id`,`status`);--> statement-breakpoint
CREATE INDEX `idx_evt_device_time` ON `events` (`device_id`,`created_at`);--> statement-breakpoint
CREATE INDEX `idx_evt_unread` ON `events` (`is_read`);--> statement-breakpoint
CREATE INDEX `idx_read_device_time` ON `sensor_readings` (`device_id`,`sampled_at`);--> statement-breakpoint
CREATE INDEX `idx_raw_device_time` ON `telemetry_raw` (`device_id`,`recorded_at`);