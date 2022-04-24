using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterHP : MonoBehaviour, IDamagable
{
    public float m_health { get; set; }

    private float m_maxHealth;
    private float m_minHealth;

    private float m_timerToRegen;

    [SerializeField]
    private UI_Manager m_ui;

    void Start()
    {
        m_minHealth = 0f;
        m_maxHealth = 100f;

        m_timerToRegen = 2f;
        m_health = m_maxHealth;
    }

    // Update is called once per frame
    void Update()
    {
        m_ui.SetHealth(m_health);

        m_timerToRegen -= Time.deltaTime;

        if (m_timerToRegen <= 0f && m_health <= 100f)
        {
            Regen();

            checkHP();

        }
    }

    private void checkHP()
    {
        if (m_health > 100f)
        {
            m_health = 100f;
        }
    }

    public void Damage()
    {
        m_timerToRegen = 2f;
        m_health -= 20f;

    }

    public void Regen()
    {
        m_health += 1f;
    }

}
