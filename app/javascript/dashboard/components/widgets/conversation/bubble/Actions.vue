<template>
  <div class="message-text--metadata">
    <span class="time">{{ readableTime }}</span>
    <span v-if="showSentIndicator" class="time">
      <i
        v-tooltip.top-start="$t('CHAT_LIST.SENT')"
        class="icon ion-checkmark"
      />
    </span>
    <i
      v-if="isEmail"
      v-tooltip.top-start="$t('CHAT_LIST.RECEIVED_VIA_EMAIL')"
      class="ion ion-android-mail"
    />
    <i
      v-if="isPrivate"
      v-tooltip.top-start="$t('CONVERSATION.VISIBLE_TO_AGENTS')"
      class="icon ion-android-lock"
      @mouseenter="isHovered = true"
      @mouseleave="isHovered = false"
    />
    <i
      v-if="isATweet && (isIncoming || isOutgoing) && sourceId"
      v-tooltip.top-start="$t('CHAT_LIST.REPLY_TO_TWEET')"
      class="icon ion-reply cursor-pointer"
      @click="onTweetReply"
    />
    <a
      v-if="isATweet && (isOutgoing || isIncoming) && linkToTweet"
      :href="linkToTweet"
      target="_blank"
      rel="noopener noreferrer nofollow"
    >
      <i
        v-tooltip.top-start="$t('CHAT_LIST.VIEW_TWEET_IN_TWITTER')"
        class="icon ion-android-open cursor-pointer"
      />
    </a>
  </div>
</template>

<script>
import { MESSAGE_TYPE } from 'shared/constants/messages';
import { BUS_EVENTS } from 'shared/constants/busEvents';
import inboxMixin from 'shared/mixins/inboxMixin';

export default {
  mixins: [inboxMixin],
  props: {
    sender: {
      type: Object,
      default: () => ({}),
    },
    readableTime: {
      type: String,
      default: '',
    },
    isEmail: {
      type: Boolean,
      default: true,
    },
    isPrivate: {
      type: Boolean,
      default: true,
    },
    isATweet: {
      type: Boolean,
      default: true,
    },
    messageType: {
      type: Number,
      default: 1,
    },
    sourceId: {
      type: String,
      default: '',
    },
    id: {
      type: [String, Number],
      default: '',
    },
    inboxId: {
      type: [String, Number],
      default: 0,
    },
  },
  computed: {
    inbox() {
      return this.$store.getters['inboxes/getInbox'](this.inboxId);
    },
    isIncoming() {
      return MESSAGE_TYPE.INCOMING === this.messageType;
    },
    isOutgoing() {
      return MESSAGE_TYPE.OUTGOING === this.messageType;
    },
    screenName() {
      const { additional_attributes: additionalAttributes = {} } =
        this.sender || {};
      return additionalAttributes?.screen_name || '';
    },
    linkToTweet() {
      if (!this.sourceId || !this.inbox.name) {
        return '';
      }
      const { screenName, sourceId } = this;
      return `https://twitter.com/${screenName ||
        this.inbox.name}/status/${sourceId}`;
    },
    showSentIndicator() {
      return this.isOutgoing && this.sourceId && this.isAnEmailChannel;
    },
  },
  methods: {
    onTweetReply() {
      bus.$emit(BUS_EVENTS.SET_TWEET_REPLY, this.id);
    },
  },
};
</script>

<style lang="scss" scoped>
@import '~dashboard/assets/scss/woot';

.right {
  .message-text--metadata {
    .time {
      color: var(--w-100);
    }
  }

  .icon {
    color: var(--white);
  }
}

.left {
  .message-text--metadata {
    .time {
      color: var(--s-400);
    }
  }
}

.message-text--metadata {
  align-items: flex-end;
  display: flex;

  .time {
    margin-right: var(--space-small);
    display: block;
    font-size: var(--font-size-micro);
    line-height: 1.8;
  }

  i {
    line-height: 1.4;
    padding-right: var(--space-small);
    padding-left: var(--space-small);
    color: var(--s-900);
  }

  a {
    color: var(--s-900);
  }
}

.activity-wrap {
  .message-text--metadata {
    .time {
      color: var(--s-300);
      display: flex;
      text-align: center;
      font-size: var(--font-size-micro);
      margin-left: 0;

      @include breakpoint(xlarge up) {
        margin-left: var(--space-small);
      }
    }
  }
}

.is-image {
  .message-text--metadata {
    .time {
      bottom: var(--space-smaller);
      color: var(--white);
      position: absolute;
      right: var(--space-small);
      white-space: nowrap;
    }
  }
}

.is-private {
  .message-text--metadata {
    align-items: flex-end;

    .time {
      color: var(--s-400);
    }

    .icon {
      color: var(--s-400);
    }
  }

  &.is-image {
    .time {
      position: inherit;
      padding-left: var(--space-one);
    }
  }
}

.delivered-icon {
  margin-left: -var(--space-normal);
}
</style>
