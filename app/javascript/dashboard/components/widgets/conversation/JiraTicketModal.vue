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
                @input="$v.email.$touch" 
                id="email" 
                class="input mb-1"
                v-bind:class="{ danger: $v.email.$error }" 
                type="email" 
                placeholder="Email">
              <span v-if="$v.email.$error" class="message mb-1">
                {{ $t('EMAIL_TRANSCRIPT.FORM.EMAIL.ERROR') }}
              </span>
          </div>
          <div>
            <label for="message">Сообщение</label>
            <textarea 
              v-model="message" 
              @input="$v.message.$touch" 
              id="message" 
              class="input mb-1"
              v-bind:class="{ danger: $v.message.$error }" 
              type="text" 
              placeholder="Сообщение" 
              rows="4">
            </textarea>
            <span v-if="$v.message.$error" class="message mb-1">
              Сообщение должно быть не короче 20 символов
            </span>
          </div>
          <div>
            <label for="dialog_category">Категория диалога</label>
            <input v-model="dialog_category" @input="$v.dialog_category.$touch" id="dialog_category" class="input" type="text" placeholder="Категория диалога">
          </div>
          <div>
            <label for="agent">Проекты</label>
            <select v-model="selectedKey">
              <option v-for="proj in projects" :value="proj.key">
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
  .mb-1 {
    margin-bottom: 1rem !important;
  }
  .danger {
    border-color: red;
  }
</style>

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
      minLength: minLength(20)
    },
    dialog_category: {},
  },
  
  watch: {
    contact() {
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
    }),
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
      this.email = this.currentChat.meta.sender.email || '';
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
