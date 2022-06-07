using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.VFX;


[RequireComponent(typeof(EnemyMovement))]
[RequireComponent(typeof(EnemyShoot))]

public class EnemyBehaviour : FiniteStateMachine, IRestartGameElement
{
    public enum State { INITIAL, WANDER, ATTACK, STUN, DEATH };

    public State m_currentState = State.INITIAL;
    
    private GameObject m_player;

    private EnemyMovement m_enemyMovement;
    private EnemyShoot m_enemyShoot;

    [Header("Attributes of the FSM")]
    [SerializeField]
    private float m_playerInRange;

    [SerializeField]
    private float m_playerOutOfRange;

    public bool m_mushroomImpact;

    private float m_stuntTime;

    private float m_antiPlayerSpam;

    [SerializeField]
    private float m_antiPlayerSpamReset;

    [SerializeField]
    private float m_stuntTimeReset;

    [SerializeField]
    private LineRenderer m_lineRenderer;

    [SerializeField]
    private Vector3 m_startPos;
    [SerializeField]
    private Quaternion m_startRot;

    [SerializeField]
    private Enemy1HP m_hp;

    [Header("Animation")]
    [SerializeField]
    private Animator m_animator;

    [Header("VFX")]
    [SerializeField]
    private VisualEffect m_arm1VFX;
    [SerializeField]
    private VisualEffect m_arm2VFX;
    [SerializeField]
    private VisualEffect m_headVFX;    
    [SerializeField]
    private Material m_golemMaterial;

    public void SetMushroomHit(bool value)
    {
        m_mushroomImpact = value;
    }

    public bool GetMushroomHit()
    {
        return m_mushroomImpact;
    }

    public float GetAntiSpamTime()
    {
        return m_antiPlayerSpam;
    }

    private void Start()
    {
        m_enemyMovement = GetComponent<EnemyMovement>();
        m_enemyShoot = GetComponent<EnemyShoot>();
        m_hp = GetComponent<Enemy1HP>();

        m_enemyMovement.enabled = false;
        m_enemyShoot.enabled = false;

        m_stuntTime = m_stuntTimeReset;

        m_startPos = transform.position;
        m_startRot = transform.rotation;

        m_golemMaterial.SetColor("_EmissionColor", new Color(56, 0, 116, 100)*0.01f);

        GameManagerScript.m_instance.AddRestartGameElement(this);
    }

    private void Update()
    {
        switch(m_currentState)
        {
            case State.INITIAL:
                ChangeState(State.WANDER);
                break;

            case State.WANDER:

                if (m_hp.m_health <= 0f) ChangeState(State.DEATH);

                m_antiPlayerSpam -= Time.deltaTime;

                // stun mushroom

                if (m_mushroomImpact && m_antiPlayerSpam <= 0f)
                {
                    ChangeState(State.STUN);
                    break;
                }

                // find player if in range

                m_player = UtilsGyromitra.FindInstanceWithinRadius(gameObject, "Player" /*UtilsGyromitra.SearchForTag("Player")*/, m_playerInRange);

                if (m_player != null)
                {
                    ChangeState(State.ATTACK);
                    break;
                }              
                break;

            case State.ATTACK:

                if (m_hp.m_health <= 0f) ChangeState(State.DEATH);

                m_antiPlayerSpam -= Time.deltaTime;

                // stun mushroom

                if (m_mushroomImpact && m_antiPlayerSpam <= 0f)
                {
                    ChangeState(State.STUN);
                    break;
                }

                // find player if out of range

                if (UtilsGyromitra.DistanceToTarget(this.gameObject, m_player) >= m_playerOutOfRange)
                {
                    ChangeState(State.WANDER);
                    break;
                }
                break;

            case State.STUN:

                if (m_hp.m_health <= 0f) ChangeState(State.DEATH);

                m_stuntTime -= Time.deltaTime;

                if (m_stuntTime <= 0f)
                {
                    m_player = UtilsGyromitra.FindInstanceWithinRadius(gameObject, "Player" /*UtilsGyromitra.SearchForTag("Player")*/, m_playerInRange);

                    // find player if in range

                    if (m_player != null)
                    {
                        ChangeState(State.ATTACK);
                        break;
                    }
                    else // find player if out of range
                    {
                        ChangeState(State.WANDER);
                        break;
                    }
                }
                break;

            case State.DEATH:

                if (m_animator.GetCurrentAnimatorStateInfo(0).IsName("Destroy"))
                {
                    Destroy(this.gameObject);
                }

                break;
        }
    }

    private void ChangeState(State l_newState)
    {
        // exit logic
        switch (m_currentState)
        {
            case State.WANDER:
                m_enemyMovement.m_navMeshAgent.isStopped = true;
                m_enemyMovement.enabled = false;
                break;

            case State.ATTACK:
                m_enemyShoot.enabled = false;
                m_lineRenderer.enabled = false;
                m_animator.SetLayerWeight(1, 0);          
                m_animator.SetBool("Aiming", false);
                m_animator.SetBool("Shoot", false);
                break;

            case State.STUN:
                m_enemyMovement.m_navMeshAgent.enabled = true;
                m_animator.SetBool("Stun", false);
                m_mushroomImpact = false;
                m_stuntTime = m_stuntTimeReset;
                m_golemMaterial.SetColor("_EmissionColor", new Color(56, 0, 116, 100)* 0.01f);
                break;
        }

        // enter logic
        switch (l_newState)
        {
            case State.WANDER:
                m_enemyMovement.m_navMeshAgent.isStopped = false;
                m_enemyMovement.enabled = true;
                m_animator.SetTrigger("Walk");
                break;  

            case State.ATTACK:
                m_enemyShoot.enabled = true;         
                m_animator.SetLayerWeight(1, 1);
                m_animator.SetBool("Aiming", true);
                m_enemyShoot.setPlayer(m_player);
                break;
                    
            case State.STUN:
                m_enemyMovement.m_navMeshAgent.enabled = false;      
                m_animator.SetBool("Stun", true);
                m_antiPlayerSpam = m_antiPlayerSpamReset;
                m_golemMaterial.SetColor("_EmissionColor", new Color(222, 58, 0, 100)* 0.01f);       
                break;

            case State.DEATH:
                m_animator.SetTrigger("Death");
                break;
        }
        m_currentState = l_newState;
    }

    public void RestartGame()
    {
        ChangeState(State.INITIAL);
        gameObject.GetComponent<Enemy1HP>().ResetHP();
        m_enemyMovement.m_navMeshAgent.enabled = false;
        transform.position = m_startPos;
        transform.rotation = m_startRot;
        m_enemyMovement.m_navMeshAgent.enabled = true;
    }
}
