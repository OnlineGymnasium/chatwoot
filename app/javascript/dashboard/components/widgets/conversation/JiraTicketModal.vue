<template>
  <woot-modal :show.sync="show" :on-close="onCancel">
    <div class="column content-box">
      <woot-modal-header
        :header-title="$t('EMAIL_TRANSCRIPT.TITLE')"
        :header-content="$t('EMAIL_TRANSCRIPT.DESC')"
      />
      <form @submit.prevent="onSubmit">
        <div class="medium-12 columns">
          <div class="column">
            <label for="email">Email</label>
              <input
                  v-model="email"
                  @blur="$v.email.$touch"
                  id="email"
                  class="input mb-4"
                  v-bind:class="{ danger: $v.email.$error }"
                  type="email"
                  placeholder="Email"
                >
                <span v-if="$v.email.$error" class="message mb-6">
                  {{ $t('EMAIL_TRANSCRIPT.FORM.EMAIL.ERROR') }}
                </span>
          </div>
          <div>
            <label for="message">Сообщение</label>
            <textarea
                v-model="message"
                @blur="$v.message.$touch"
                id="message"
                class="input mb-4"
                v-bind:class="{ danger: $v.message.$error }"
                type="text"
                placeholder="Сообщение (минимум 30 символов)"
                rows="4"
              >
            </textarea>
            <span v-if="$v.message.$error" class="message mb-6">
              Сообщение должно быть не короче 30 символов
            </span>
          </div>
          <div>
            <label for="dialog_category">Категория диалога</label>
            <input
              v-model="dialog_category"
              @blur="$v.dialog_category.$touch"
              id="dialog_category"
              class="input mb-4"
              v-bind:class="{ danger: $v.dialog_category.$error }"
              type="text"
              placeholder="Категория диалога (минимум 10 символов)"
            >
            <span v-if="$v.dialog_category.$error" class="message mb-6">
              Категория должна быть не короче 10 символов
            </span>
          </div>
          <div>
            <label for="agent">Проекты</label>
            <select v-model="selectedKey" required="true">
              <option 
                v-for="(proj, index) in projects" 
                v-bind:value="proj.key" 
                v-bind:key=index
              >
                {{ proj.name }}
              </option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <div class="medium-12 row">
            <woot-submit-button
              :button-text="$t('EMAIL_TRANSCRIPT.SUBMIT')"
            />
            <button class="button clear" @click.prevent="onCancel">
              {{ $t('EMAIL_TRANSCRIPT.CANCEL') }}
            </button>
          </div>
        </div>
      </form>
    </div>
  </woot-modal>
</template>

<style scoped>
  .mb-4 {
    margin-bottom: 1rem !important;
  }
  .mb-6 {
    margin-bottom: 1.5rem !important;
  }
  .danger {
    border-color: red;
  }
</style>

<script>
import { mapGetters } from 'vuex';
import { validationMixin } from 'vuelidate'
import { required, minLength, email } from 'vuelidate/lib/validators';
import alertMixin from 'shared/mixins/alertMixin';

export default {
  mixins: [alertMixin, validationMixin],
  props: {
    contact: {
      type: Object,
      default: () => ({}),
    },
    show: {
      type: Boolean,
      default: false,
    },

  },
  data() {
    return {
      selectedKey: null,
      isSubmitting: false,
      isLoading: true,
      email: "",
      username: "",
      browser: "",
      os: "",
      message: "",
      first_appeal: "",
      dialog_category: "",
      begin_link: "",
    };
  },
  validations: {
    email: {
      required,
      email
    },
    message: {
      required,
      minLength: minLength(30)
    },
    dialog_category: {
      required,
      minLength: minLength(10)
    },
  },

  watch: {
    contact() {
      this.setTicketObject();
    },
    projects() {
      this.setDefaultProject();
    },
    currentChat(){
      this.setTicketObject();
    },
  },
  mounted() {
    this.isLoading = true;
    try {
      this.$store.dispatch('getProjects');
      this.setTicketObject();
    } catch (error) {
      this.showAlert(this.$t('EMAIL_TRANSCRIPT.SEND_EMAIL_ERROR'));
    } finally {
      this.isLoading = false;
    }
  },
  computed: {
    ...mapGetters({
      projects: 'getProjects',
      jiraTicketResponse: 'getJiraTicketResponse',
      currentUser: 'getCurrentUser',
      currentChat: 'getSelectedChat',
      allConversations: 'getAllConversations',
      activeInbox: 'getSelectedInbox',
    }),
    inbox() {
      return this.$store.getters['inboxes/getInbox'](this.currentChat.inbox_id);
    },
    currentContact() {
      return this.$store.getters['contacts/getContact'](
      this.currentChat.meta.sender.id);
    },
  },
  methods: {
    onCancel() {
      this.$emit('cancel');
    },
    onSuccess() {
      this.$emit('success');
    },
    getMessages() {
      const [chat] = this.allConversations.filter(
        c => c.id === this.currentChat.id
      );

      return chat;
    },
    setTicketObject() {
      this.email = this.currentContact.email || '';
    },
    getTicketObject() {
      return {
        email: this.email && this.email != "" ? this.email : this.currentChat.meta.sender.name,
        username: this.currentChat.meta.sender.name,
        browser: this.currentChat.additional_attributes.browser.browser_name,
        os: this.currentChat.additional_attributes.browser.platform_name,
        message: this.message,
        first_appeal: this.currentChat.additional_attributes.initiated_at.timestamp,
        dialog_category: this.dialog_category,
        begin_link: this.currentChat.additional_attributes.referer,
        projectKey: this.selectedKey,
        messages: this.getMessages(),
      };
    },
    setDefaultProject() {
      this.projects.forEach(({key, name}) => {
        if (this.inbox?.name?.trim().toLowerCase() == name.trim().toLowerCase()) {
          this.selectedKey = key
        }
      })
    },
    async onSubmit() {
      this.$v.$touch();

      if (this.$v.$invalid) {
        return;
      }
      try {
        const saved = await this.$store.dispatch('sendJiraTicket', this.getTicketObject());
        this.onSuccess();
        this.showAlert("Тикет успешно отправлен в Jira!");
        this.onCancel();
      } catch (error) {
        this.showAlert("Произошла ошибка!");
      }
    },
  },
};
</script>
