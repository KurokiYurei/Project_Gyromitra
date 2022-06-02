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

    [Header("Health Shader")]
    [SerializeField]
    private Material m_quiverShader;
    [SerializeField]
    private float m_healthColorLimit;
    [SerializeField]
    private Color m_fullHealthColor;
    [SerializeField]
    private Color m_damagedHealthColor;

    void Start()
    {
        m_minHealth = 0f;
        m_maxHealth = 100f;

        m_timerToRegen = 2f;
        m_startTimeToRegen = 2f;
        m_healthPerSecond = 10f;
        m_tickPerSecondHealth = 1f;

        m_health = m_maxHealth;

        m_healthColorLimit = 90;
        m_fullHealthColor = new Color(9, 191, 0, 255)*0.5f;
        m_damagedHealthColor = new Color(0, 99, 191, 255)*0.5f;
    }

    void Update()
    {
        m_ui.SetHealth(m_health);

        m_quiverShader.SetFloat("_Fill", m_health/100f);

        if (m_health >= m_healthColorLimit) m_quiverShader.SetColor("_EmissionColor", m_fullHealthColor);
        else m_quiverShader.SetColor("_EmissionColor", m_damagedHealthColor);

        m_timerToRegen -= Time.deltaTime;

        if (m_timerToRegen <= 0f && m_health <= 100f)
        {
            m_tickPerSecondHealth -= Time.deltaTime;

            if (m_tickPerSecondHealth <= 0f)
            {
                Regen();
                m_tickPerSecondHealth = 1f;
            }
        }
    }

    /// <summary>
    /// Deal damage to the player
    /// </summary>
    /// <param name="damage"></param>
    public void Damage(float damage)
    {
        m_timerToRegen = m_startTimeToRegen;
        m_health -= damage;
        if (m_health <= m_minHealth)
        {
            //gameObject.GetComponent<CharacterControllerScript>().m_gameManager.RestartGame();
            GameManagerScript.m_instance.RestartGame();
        }
    }

    /// <summary>
    /// regen function
    /// </summary>
    public void Regen()
    {
        if(m_health >= m_maxHealth)
        {
            m_health = m_maxHealth;
        }
        else
        {
            m_health += m_healthPerSecond;
        }
    }

    /// <summary>
    /// reset hp of the player
    /// </summary>
    public void ResetHP()
    {
        m_health = m_maxHealth;
    }
}
