<?php

namespace App\Services\Contact\Contact;

use App\Services\BaseService;
use App\Models\Contact\Contact;
use App\Services\Contact\Avatar\GenerateDefaultAvatar;

class UpdateContact extends BaseService
{
    private $contact;

    /**
     * Get the validation rules that apply to the service.
     *
     * @return array
     */
    public function rules()
    {
        return [
            'account_id' => 'required|integer|exists:accounts,id',
            'contact_id' => 'required|integer',
            'first_name' => 'required|string|max:255',
            'middle_name' => 'nullable|string|max:255',
            'last_name' => 'nullable|string|max:255',
            'nickname' => 'nullable|string|max:255',
            'gender_id' => 'required|integer|exists:genders,id',
            'description' => 'nullable|string|max:255',
            'is_partial' => 'nullable|boolean',
            'is_birthdate_known' => 'nullable|boolean',
            'birthdate_day' => 'nullable|integer',
            'birthdate_month' => 'nullable|integer',
            'birthdate_year' => 'nullable|integer',
            'birthdate_is_age_based' => 'nullable|boolean',
            'birthdate_age' => 'nullable|integer',
            'birthdate_add_reminder' => 'nullable|boolean',
            'is_deceased' => 'nullable|boolean',
            'is_deceased_date_known' => 'nullable|boolean',
            'deceased_date_day' => 'nullable|integer',
            'deceased_date_month' => 'nullable|integer',
            'deceased_date_year' => 'nullable|integer',
            'deceased_date_add_reminder' => 'nullable|boolean',
        ];
    }

    /**
     * Update a contact.
     *
     * @param array $data
     * @return Contact
     */
    public function execute(array $data) : Contact
    {
        $this->validate($data);

        // filter out the data that shall not be updated here
        $dataOnly = array_except(
            $data, [
                'is_birthdate_known',
                'birthdate_day',
                'birthdate_month',
                'birthdate_year',
                'birthdate_is_age_based',
                'birthdate_age',
                'birthdate_add_reminder',
            ]
        );

        $this->contact = Contact::where('account_id', $data['account_id'])
            ->findOrFail($data['contact_id']);

        $oldName = $this->contact->name;

        $this->contact->update($dataOnly);

        // only update the avatar if the name has changed
        if ($oldName != $this->contact->name) {
            $this->updateDefaultAvatar();
        }

        $this->updateBirthDayInformation($data);

        $this->updateDeceasedInformation($data);

        return $this->contact;
    }

    /**
     * Update the default avatar.
     *
     * @return void
     */
    private function updateDefaultAvatar()
    {
        $this->contact = (new GenerateDefaultAvatar)->execute([
            'contact_id' => $this->contact->id,
        ]);
    }

    /**
     * Update the information about the birthday.
     *
     * @param array $data
     * @return void
     */
    private function updateBirthDayInformation(array $data)
    {
        (new UpdateBirthdayInformation)->execute([
            'account_id' => $data['account_id'],
            'contact_id' => $this->contact->id,
            'is_date_known' => $data['is_birthdate_known'],
            'day' => $data['birthdate_day'],
            'month' => $data['birthdate_month'],
            'year' => $data['birthdate_year'],
            'is_age_based' => $data['birthdate_is_age_based'],
            'age' => $data['birthdate_age'],
            'add_reminder' => $data['birthdate_add_reminder'],
        ]);
    }

    /**
     * Update the information about the date of death.
     *
     * @param array $data
     * @return void
     */
    private function updateDeceasedInformation(array $data)
    {
        (new UpdateDeceasedInformation)->execute([
            'account_id' => $data['account_id'],
            'contact_id' => $this->contact->id,
            'is_deceased' => $data['is_deceased'],
            'is_date_known' => $data['is_deceased_date_known'],
            'day' => $data['deceased_date_day'],
            'month' => $data['deceased_date_month'],
            'year' => $data['deceased_date_year'],
            'add_reminder' => $data['deceased_date_add_reminder'],
        ]);
    }
}
