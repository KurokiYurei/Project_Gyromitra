using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterHP : MonoBehaviour, IDamagable
{
    public float m_health { get; set; }

    private float m_maxHealth;
    private float m_minHealth;

    private float m_startTimeToRegen;

    [SerializeField]
    private float m_timerToRegen;

    [SerializeField]
    private float m_tickPerSecondHealth;

    private float m_healthPerSecond;

    [SerializeField]
    private UI_Manager m_ui;

    void Start()
    {
        m_minHealth = 0f;
        m_maxHealth = 100f;

        m_timerToRegen = 10f;
        m_startTimeToRegen = 10f;
        m_healthPerSecond = 10f;
        m_tickPerSecondHealth = 1f;

        m_health = m_maxHealth;
    }

    // Update is called once per frame
    void Update()
    {
        m_ui.SetHealth(m_health);

        m_timerToRegen -= Time.deltaTime;

        if (m_timerToRegen <= 0f && m_health <= 100f)
        {
            m_tickPerSecondHealth -= Time.deltaTime;

            if (m_tickPerSecondHealth <= 0f)
            {
                Regen();
                checkHP();
                m_tickPerSecondHealth = 1f;
            }
        }
    }

    private void checkHP()
    {
        if (m_health > 100f)
        {
            m_health = 100f;
        }

        if (m_health < 0f)
        {
            m_health = 0f;
            // morir
        }
    }

    public void Damage(float damage)
    {
        m_timerToRegen = m_startTimeToRegen;
        m_health -= damage;

    }

    public void Regen()
    {
        m_health += m_healthPerSecond;
    }

}
